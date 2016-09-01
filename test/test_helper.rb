require "bundler/setup"
Bundler.require(:default)
require "minitest/autorun"
require "minitest/pride"
require "combustion"

Minitest::Test = Minitest::Unit::TestCase unless defined?(Minitest::Test)

Combustion.path = "test/internal"
Combustion.initialize! :all

ActionMailer::Base.delivery_method = :test

ActiveRecord::Base.belongs_to_required_by_default = true if ActiveRecord::VERSION::MAJOR >= 5
