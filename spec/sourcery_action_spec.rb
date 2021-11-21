describe Fastlane::Actions::SourceryAction do
  describe 'Sourcery action' do
    it 'should run sourcery when params are empty' do
      expect(Fastlane::Actions).to receive(:sh).with("sourcery")

      Fastlane::Actions::SourceryAction.run(nil)
    end
  end
end
