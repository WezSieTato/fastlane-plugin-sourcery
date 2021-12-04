lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fastlane/plugin/sourcery/version'

Gem::Specification.new do |spec|
  spec.name          = 'fastlane-plugin-sourcery'
  spec.version       = Fastlane::Sourcery::VERSION
  spec.author        = 'Marcin Stepnowski'
  spec.email         = 'marcin.stepnowski@gmail.com'

  spec.summary       = "Run sourcery with fastlane! Sourcery is a code generator for Swift language, built on top of Apple's own SwiftSyntax. It extends the language abstractions to allow you to generate boilerplate code automatically."
  spec.homepage      = "https://github.com/WezSieTato/fastlane-plugin-sourcery"
  spec.license       = "MIT"

  spec.files         = Dir["lib/**/*"] + %w(README.md LICENSE)
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.5'

  spec.add_development_dependency('bundler')
  spec.add_development_dependency('codecov')
  spec.add_development_dependency('fastlane', '>= 2.198.1')
  spec.add_development_dependency('pry')
  spec.add_development_dependency('rake')
  spec.add_development_dependency('rspec')
  spec.add_development_dependency('rspec_junit_formatter')
  spec.add_development_dependency('rubocop', '1.12.1')
  spec.add_development_dependency('rubocop-performance')
  spec.add_development_dependency('rubocop-require_tools')
  spec.add_development_dependency('simplecov')
end
