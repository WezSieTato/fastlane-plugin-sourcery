$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))

require 'simplecov'
require 'simplecov-lcov'

SimpleCov::Formatter::LcovFormatter.config.report_with_single_file = true
SimpleCov::Formatter::LcovFormatter.config.single_report_path = 'coverage/lcov.info'
SimpleCov.formatter = SimpleCov::Formatter::LcovFormatter
SimpleCov.start

module SpecHelper
end

require 'fastlane'
require 'fastlane/plugin/sourcery'
require 'action_runner'

Fastlane.load_actions
