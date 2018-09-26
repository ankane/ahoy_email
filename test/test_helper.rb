require "bundler/setup"
Bundler.require(:default)
require "minitest/autorun"
require "minitest/pride"
require "combustion"

Combustion.path = "test/internal"
Combustion.initialize! :all do
  if config.active_record.sqlite3.respond_to?(:represent_boolean_as_integer)
    config.active_record.sqlite3.represent_boolean_as_integer = true
  end
end

ActionMailer::Base.delivery_method = :test
