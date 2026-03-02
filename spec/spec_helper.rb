$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))

require 'simplecov'

SimpleCov.start

module SpecHelper
end

require 'fastlane'
require 'fastlane/plugin/sourcery'
require 'action_runner'

Fastlane.load_actions
