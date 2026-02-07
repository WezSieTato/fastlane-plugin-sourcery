require 'fastlane'
require 'fileutils'

module Fastlane
  module Actions
    class GetSourceryAction < Action
      def self.run(params)
        version = params[:version]
        target_directory = File.expand_path(params[:target_directory])

        UI.message("Getting Sourcery version #{version}")

        # Ensure target directory exists
        FileUtils.mkdir_p(target_directory)

        # Check if Sourcery is already installed
        target_executable = File.join(target_directory, "sourcery")
        if File.exist?(target_executable)
          current_version = `#{target_executable} --version`.strip
          if current_version == version
            UI.message("Sourcery version #{version} is already installed at #{target_executable}")
            ENV['SOURCERY_EXECUTABLE'] = target_executable
            return target_executable
          else
            UI.message("Found Sourcery version #{current_version}, but required version is #{version}. Re-downloading...")
          end
        end

        # Create temporary directory for download
        temp_dir = File.join(target_directory, "temp_download_#{Time.now.to_i}")
        FileUtils.mkdir_p(temp_dir)

        zip_path = File.join(temp_dir, "sourcery-#{version}.zip")

        # Construct download URL
        download_url = "https://github.com/krzysztofzablocki/Sourcery/releases/download/#{version}/sourcery-#{version}.zip"

        # Download
        UI.message("Downloading Sourcery from #{download_url} to #{zip_path}")
        sh("curl -L -o #{zip_path} #{download_url}")

        # Unzip
        UI.message("Unzipping Sourcery...")
        sh("unzip -o #{zip_path} -d #{temp_dir}")

        # Remove zip
        FileUtils.rm(zip_path)

        # Move executable to target directory
        extracted_executable = File.join(temp_dir, "bin", "sourcery")
        target_executable = File.join(target_directory, "sourcery")

        # Check if executable exists in bin/sourcery (standard structure)
        unless File.exist?(extracted_executable)
          # Fallback: check directly in temp dir
          extracted_executable = File.join(temp_dir, "sourcery")
        end

        if File.exist?(extracted_executable)
          UI.message("Moving executable to #{target_executable}...")
          # Ensure target directory is clean for the new executable if it already exists (though we checked version before)
          FileUtils.rm_f(target_executable)
          FileUtils.mv(extracted_executable, target_executable)
        else
          UI.user_error!("Could not find Sourcery executable in downloaded archive")
        end

        # Cleanup temp directory
        UI.message("Cleaning up temporary files...")
        FileUtils.rm_rf(temp_dir)

        executable_path = target_executable

        unless File.exist?(executable_path)
          UI.user_error!("Could not find Sourcery executable at path '#{executable_path}'")
        end

        # Set environment variable
        UI.message("Setting SOURCERY_EXECUTABLE to #{executable_path}")
        ENV['SOURCERY_EXECUTABLE'] = executable_path

        return executable_path
      end

      def self.description
        "Downloads a specific version of Sourcery from GitHub and sets up the environment"
      end

      def self.authors
        ["Marcin Stepnowski"]
      end

      def self.return_value
        "The absolute path to the downloaded Sourcery executable"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :version,
                                       description: "The version of Sourcery to download (e.g. '2.1.2')",
                                       optional: false,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :target_directory,
                                       description: "The directory to download and extract Sourcery to",
                                       optional: true,
                                       default_value: "./sourcery_bin",
                                       type: String)
        ]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end

      def self.category
        :building
      end
    end
  end
end
