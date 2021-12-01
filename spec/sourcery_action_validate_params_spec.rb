describe Fastlane::Actions::SourceryAction do
  describe 'Sourcery action' do
    it 'should succed config validation when file exist' do
      expect(Fastlane::UI).not_to(receive(:user_error!))

      ActionRunner.sourcery("config: '../spec/.fake_sourcery.yml'")
    end

    it 'should fail config validation when file not exist' do
      expect(Fastlane::UI)
        .to receive(:user_error!)
        .with(match("Couldn't find config path"))

      ActionRunner.sourcery("config: 'non_existing_file.yml'")
    end

    it 'should succed executable validation when file exist' do
      expect(Fastlane::UI).not_to(receive(:user_error!))

      ActionRunner.sourcery("executable: '../spec/fake_sourcery'")
    end

    it 'should fail executable validation when file not exist' do
      expect(Fastlane::UI)
        .to receive(:user_error!)
        .with(match("Couldn't find executable path"))

      ActionRunner.sourcery("executable: 'non_existing_file'")
    end
  end
end
