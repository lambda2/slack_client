# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'slack_client/version'

Gem::Specification.new do |spec|
  spec.name          = "slack_client"
  spec.version       = SlackClient::VERSION
  spec.authors       = ["Andre Aubin"]
  spec.email         = ["andre.aubin@lambdaweb.fr"]
  spec.summary       = %q{A slack client implementation, in ruby}
  spec.description   = %q{A Slack client implementation in ruby, working with ws}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
