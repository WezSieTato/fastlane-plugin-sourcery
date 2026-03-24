describe Fastlane::Actions::GetSourceryAction do
  let(:tmp_dir) { Dir.mktmpdir('get_sourcery_test') }
  let(:version) { '2.1.2' }

  after(:each) do
    FileUtils.rm_rf(tmp_dir)
    ENV.delete('SOURCERY_EXECUTABLE')
  end

  describe 'run' do
    context 'when Sourcery is already installed with correct version' do
      before do
        executable_path = File.join(tmp_dir, 'sourcery')
        File.write(executable_path, "#!/bin/bash\necho '#{version}'")
        File.chmod(0o755, executable_path)
      end

      it 'returns early without downloading' do
        expect(described_class).not_to(receive(:sh))

        result = ActionRunner.get_sourcery("version: '#{version}', target_directory: '#{tmp_dir}'")
        expect(result).to eq(File.join(tmp_dir, 'sourcery'))
      end

      it 'sets SOURCERY_EXECUTABLE environment variable' do
        ActionRunner.get_sourcery("version: '#{version}', target_directory: '#{tmp_dir}'")
        expect(ENV['SOURCERY_EXECUTABLE']).to eq(File.join(tmp_dir, 'sourcery'))
      end
    end

    context 'when Sourcery is already installed with different version' do
      before do
        executable_path = File.join(tmp_dir, 'sourcery')
        File.write(executable_path, "#!/bin/bash\necho '1.0.0'")
        File.chmod(0o755, executable_path)
      end

      it 'downloads the requested version' do
        allow(described_class).to receive(:sh) do |cmd|
          if cmd.include?('curl')
            zip_path = cmd.match(/-o\s+(\S+)/)[1]
            FileUtils.touch(zip_path)
          elsif cmd.include?('unzip')
            temp_dir_path = cmd.match(/-d\s+(\S+)/)[1]
            bin_dir = File.join(temp_dir_path, 'bin')
            FileUtils.mkdir_p(bin_dir)
            File.write(File.join(bin_dir, 'sourcery'), 'fake_binary')
          end
        end

        result = ActionRunner.get_sourcery("version: '#{version}', target_directory: '#{tmp_dir}'")
        expect(result).to eq(File.join(tmp_dir, 'sourcery'))
      end
    end

    context 'when Sourcery is not installed' do
      it 'downloads and extracts Sourcery from bin/ structure' do
        allow(described_class).to receive(:sh) do |cmd|
          if cmd.include?('curl')
            zip_path = cmd.match(/-o\s+(\S+)/)[1]
            FileUtils.touch(zip_path)
          elsif cmd.include?('unzip')
            temp_dir_path = cmd.match(/-d\s+(\S+)/)[1]
            bin_dir = File.join(temp_dir_path, 'bin')
            FileUtils.mkdir_p(bin_dir)
            File.write(File.join(bin_dir, 'sourcery'), 'fake_binary')
          end
        end

        result = ActionRunner.get_sourcery("version: '#{version}', target_directory: '#{tmp_dir}'")

        executable_path = File.join(tmp_dir, 'sourcery')
        expect(result).to eq(executable_path)
        expect(File.exist?(executable_path)).to be(true)
      end

      it 'falls back to sourcery directly in temp dir when bin/ not found' do
        allow(described_class).to receive(:sh) do |cmd|
          if cmd.include?('curl')
            zip_path = cmd.match(/-o\s+(\S+)/)[1]
            FileUtils.touch(zip_path)
          elsif cmd.include?('unzip')
            temp_dir_path = cmd.match(/-d\s+(\S+)/)[1]
            File.write(File.join(temp_dir_path, 'sourcery'), 'fake_binary')
          end
        end

        result = ActionRunner.get_sourcery("version: '#{version}', target_directory: '#{tmp_dir}'")

        executable_path = File.join(tmp_dir, 'sourcery')
        expect(result).to eq(executable_path)
        expect(File.exist?(executable_path)).to be(true)
      end

      it 'calls curl with correct download URL' do
        expected_url = "https://github.com/krzysztofzablocki/Sourcery/releases/download/#{version}/sourcery-#{version}.zip"

        expect(described_class).to receive(:sh).with(include('curl'), any_args) do |cmd|
          expect(cmd).to include(expected_url)
          zip_path = cmd.match(/-o\s+(\S+)/)[1]
          FileUtils.touch(zip_path)
        end

        allow(described_class).to receive(:sh).with(include('unzip'), any_args) do |cmd|
          temp_dir_path = cmd.match(/-d\s+(\S+)/)[1]
          bin_dir = File.join(temp_dir_path, 'bin')
          FileUtils.mkdir_p(bin_dir)
          File.write(File.join(bin_dir, 'sourcery'), 'fake_binary')
        end

        ActionRunner.get_sourcery("version: '#{version}', target_directory: '#{tmp_dir}'")
      end

      it 'cleans up temporary directory after extraction' do
        allow(described_class).to receive(:sh) do |cmd|
          if cmd.include?('curl')
            zip_path = cmd.match(/-o\s+(\S+)/)[1]
            FileUtils.touch(zip_path)
          elsif cmd.include?('unzip')
            temp_dir_path = cmd.match(/-d\s+(\S+)/)[1]
            bin_dir = File.join(temp_dir_path, 'bin')
            FileUtils.mkdir_p(bin_dir)
            File.write(File.join(bin_dir, 'sourcery'), 'fake_binary')
          end
        end

        ActionRunner.get_sourcery("version: '#{version}', target_directory: '#{tmp_dir}'")

        temp_dirs = Dir.glob(File.join(tmp_dir, 'temp_download_*'))
        expect(temp_dirs).to be_empty
      end

      it 'sets SOURCERY_EXECUTABLE environment variable' do
        allow(described_class).to receive(:sh) do |cmd|
          if cmd.include?('curl')
            zip_path = cmd.match(/-o\s+(\S+)/)[1]
            FileUtils.touch(zip_path)
          elsif cmd.include?('unzip')
            temp_dir_path = cmd.match(/-d\s+(\S+)/)[1]
            bin_dir = File.join(temp_dir_path, 'bin')
            FileUtils.mkdir_p(bin_dir)
            File.write(File.join(bin_dir, 'sourcery'), 'fake_binary')
          end
        end

        ActionRunner.get_sourcery("version: '#{version}', target_directory: '#{tmp_dir}'")

        expect(ENV['SOURCERY_EXECUTABLE']).to eq(File.join(tmp_dir, 'sourcery'))
      end

      it 'raises error when executable not found in archive' do
        allow(described_class).to receive(:sh) do |cmd|
          if cmd.include?('curl')
            zip_path = cmd.match(/-o\s+(\S+)/)[1]
            FileUtils.touch(zip_path)
          end
          # unzip mock does not create any executable
        end

        # In real execution, user_error! raises and stops execution.
        # In tests, the mock returns nil so execution continues to a second check.
        expect(Fastlane::UI)
          .to receive(:user_error!)
          .with("Could not find Sourcery executable in downloaded archive")
          .ordered

        expect(Fastlane::UI)
          .to receive(:user_error!)
          .with(match("Could not find Sourcery executable at path"))
          .ordered

        ActionRunner.get_sourcery("version: '#{version}', target_directory: '#{tmp_dir}'")
      end
    end
  end

  describe 'metadata' do
    it 'has correct description' do
      expect(described_class.description).to eq("Downloads a specific version of Sourcery from GitHub and sets up the environment")
    end

    it 'has correct authors' do
      expect(described_class.authors).to eq(["Marcin Stepnowski"])
    end

    it 'has correct return_value' do
      expect(described_class.return_value).to eq("The absolute path to the downloaded Sourcery executable")
    end

    it 'has correct category' do
      expect(described_class.category).to eq(:building)
    end

    it 'supports iOS platform' do
      expect(described_class.is_supported?(:ios)).to be(true)
    end

    it 'supports Mac platform' do
      expect(described_class.is_supported?(:mac)).to be(true)
    end

    it 'does not support Android platform' do
      expect(described_class.is_supported?(:android)).to be(false)
    end

    it 'has version and target_directory options' do
      options = described_class.available_options
      expect(options.length).to eq(2)
      expect(options.map(&:key)).to contain_exactly(:version, :target_directory)
    end

    it 'has version as required option' do
      version_option = described_class.available_options.find { |o| o.key == :version }
      expect(version_option.optional).to be(false)
    end

    it 'has target_directory as optional with default value' do
      target_option = described_class.available_options.find { |o| o.key == :target_directory }
      expect(target_option.optional).to be(true)
      expect(target_option.default_value).to eq("./sourcery_bin")
    end
  end
end
