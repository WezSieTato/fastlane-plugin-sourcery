describe Fastlane::Actions::SourceryAction do
  describe '#run' do
    it 'prints a message' do
      expect(Fastlane::UI).to receive(:message).with("The sourcery plugin is working!")

      Fastlane::Actions::SourceryAction.run(nil)
    end
  end
end
