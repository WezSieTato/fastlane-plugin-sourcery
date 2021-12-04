require 'fastlane'

module Fastlane
  module Actions
    class SourceryAction < Action
      def self.run(params)
        require 'shellwords'

        cmd = []
        cmd << (params[:executable] || "sourcery").dup
        config = params[:config]
        if config
          cmd << "--config"
          cmd << config
        end

        Actions.sh(Shellwords.join(cmd))
      end

      def self.description
        "Sourcery is a code generator for Swift language, built on top of Apple's own SwiftSyntax. It extends the language abstractions to allow you to generate boilerplate code automatically."
      end

      def self.authors
        ["Marcin Stepnowski"]
      end

      def self.example_code
        [
          "sourcery",
          "
          sourcery(
            executable: \"Sourcery-Example/Pods/Sourcery/bin/sourcery\",
            config: \"Sourcery-Example/.sourcery.yml\"
          )
          "
        ]
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :executable,
                                  env_name: "SOURCERY_EXECUTABLE",
                               description: "Path to Sourcery executable. Defaults to Sourcery in your PATH",
                                  optional: true,
                                      type: String,
                              verify_block: proc do |value|
                                UI.user_error!("Couldn't find executable path '#{File.expand_path(value)}'") unless File.exist?(value)
                              end),
          FastlaneCore::ConfigItem.new(key: :config,
                                  env_name: "SOURCERY_CONFIG",
                               description: "Path to config file. File or Directory. See https://github.com/krzysztofzablocki/Sourcery#configuration-file",
                                  optional: true,
                                  type: String,
                                  verify_block: proc do |value|
                                    UI.user_error!("Couldn't find config path '#{File.expand_path(value)}'") unless File.exist?(value)
                                  end)
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
