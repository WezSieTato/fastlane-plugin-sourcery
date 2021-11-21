describe Fastlane::Actions::SourceryAction do
  describe 'Sourcery action' do
    it 'should succed config validation when file exist' do
      expect(Fastlane::UI).not_to(receive(:user_error!))

      ActionRunner.sourcery("config: '../spec/.fake_sourcery.yml'")
    end

    it 'should fail config validation when file exist' do
      expect(Fastlane::UI)
        .to receive(:user_error!)
        .with(match("Couldn't find config path"))

      ActionRunner.sourcery("config: 'non_existing_file.yml'")
    end
  end
end
