# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'barchart/version'

Gem::Specification.new do |spec|
  spec.name = 'barchart'
  spec.version = Barchart::VERSION
  spec.authors = ['Joseph Bridgwater-Rowe']
  spec.email = ['joe@westernmilling.com']
  spec.homepage = 'https://github.com/westernmilling/barchart'
  spec.platform = Gem::Platform::RUBY

  spec.summary = 'barchart.com API Client.'
  spec.description = ''
  spec.license = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = 'bin'
  spec.executables << 'agent'
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'activesupport', '~> 6'
  spec.add_runtime_dependency 'dotenv', '2.7.5'
  spec.add_runtime_dependency 'gli', '2.19.0'
  spec.add_runtime_dependency 'httparty', '0.17.3'
  spec.add_runtime_dependency 'json-api-vanilla', '1.0.2'

  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'factory_bot', '5.1.1'
  spec.add_development_dependency 'faker', '2.10.1'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec_junit_formatter', '0.4.1'
  spec.add_development_dependency 'rubocop', '0.76.0'
  spec.add_development_dependency 'simplecov', '0.17.1'
  spec.add_development_dependency 'webmock', '~> 3.8'
end
