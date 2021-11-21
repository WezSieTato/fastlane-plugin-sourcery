describe Fastlane::Actions::SourceryAction do
  describe 'Sourcery action should run' do
    it 'without parameter' do
      expect(Fastlane::Actions).to receive(:sh).with("sourcery")

      ActionRunner.sourcery("")
    end

    it 'with config param' do
      expect(Fastlane::Actions).to receive(:sh).with("sourcery --config ../spec/.fake_sourcery.yml")

      ActionRunner.sourcery("config: '../spec/.fake_sourcery.yml'")
    end
  end
end
