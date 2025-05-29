require_relative "test_helper"

require "rails/generators/test_case"
require "generators/ahoy/clicks_generator"

class ClicksGeneratorTest < Rails::Generators::TestCase
  tests Ahoy::Generators::ClicksGenerator
  destination File.expand_path("../tmp", __dir__)
  setup :prepare_destination

  def test_works
    run_generator
    if mongoid?
      assert_file "app/models/ahoy/click.rb"
    else
      assert_migration "db/migrate/create_ahoy_clicks.rb", /create_table :ahoy_clicks/
    end
  end

  def test_primary_key_type
    skip if mongoid?
    Rails.configuration.generators.stub(:options, {active_record: {primary_key_type: :uuid}}) do
      run_generator
    end
    assert_migration "db/migrate/create_ahoy_clicks.rb", /id: :uuid/
  end
end
