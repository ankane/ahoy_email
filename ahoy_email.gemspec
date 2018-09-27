
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ahoy_email/version"

Gem::Specification.new do |spec|
  spec.name          = "ahoy_email"
  spec.version       = AhoyEmail::VERSION
  spec.summary       = "Email analytics for Rails"
  spec.homepage      = "https://github.com/ankane/ahoy_email"
  spec.license       = "MIT"

  spec.author        = "Andrew Kane"
  spec.email         = "andrew@chartkick.com"

  spec.files         = Dir["*.{md,txt}", "{app,config,lib}/**/*"]
  spec.require_path  = "lib"

  spec.required_ruby_version = ">= 2.2"

  spec.add_dependency "railties", ">= 4.2"
  spec.add_dependency "actionmailer", ">= 4.2"
  spec.add_dependency "activerecord", ">= 4.2"
  spec.add_dependency "addressable", ">= 2.3.2"
  spec.add_dependency "nokogiri"
  spec.add_dependency "safely_block", ">= 0.1.1"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "combustion"
  spec.add_development_dependency "rails"
  spec.add_development_dependency "sqlite3"
end
