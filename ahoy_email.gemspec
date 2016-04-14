# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ahoy_email/version"

Gem::Specification.new do |spec|
  spec.name          = "ahoy_email"
  spec.version       = AhoyEmail::VERSION
  spec.authors       = ["Andrew Kane"]
  spec.email         = ["andrew@chartkick.com"]
  spec.summary       = "Simple, powerful email tracking for Rails"
  spec.description   = "Simple, powerful email tracking for Rails"
  spec.homepage      = "https://github.com/ankane/ahoy_email"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "rails"
  spec.add_runtime_dependency "addressable"
  spec.add_runtime_dependency "nokogiri"
  spec.add_runtime_dependency "safely_block"
  spec.add_runtime_dependency "aws-sdk", "~> 2"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "combustion"
  spec.add_development_dependency "sqlite3"
end
