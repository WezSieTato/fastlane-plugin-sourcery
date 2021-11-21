require 'fastlane_core/ui/ui'

module Fastlane
  UI = FastlaneCore::UI unless Fastlane.const_defined?("UI")

  module Helper
    class SourceryHelper
      # class methods that you define here become available in your action
      # as `Helper::SourceryHelper.your_method`
      #
      def self.show_message
        UI.message("Hello from the sourcery plugin helper!")
      end
    end
  end
end
