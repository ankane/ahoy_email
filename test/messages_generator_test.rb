require_relative "test_helper"

require "rails/generators/test_case"
require "generators/ahoy/messages_generator"

class MessagesGeneratorTest < Rails::Generators::TestCase
  tests Ahoy::Generators::MessagesGenerator
  destination File.expand_path("../tmp", __dir__)
  setup :prepare_destination

  def test_encryption_lockbox
    run_generator ["--encryption=lockbox"]
    assert_file "app/models/ahoy/message.rb", /has_encrypted :to/
    assert_migration "db/migrate/create_ahoy_messages.rb", /t.text :to_ciphertext/ unless mongoid?
  end

  def test_encryption_activerecord
    skip if mongoid?
    run_generator ["--encryption=activerecord"]
    assert_file "app/models/ahoy/message.rb", /encrypts :to, deterministic: true/
    assert_migration "db/migrate/create_ahoy_messages.rb", /t.string :to, index: true/
  end

  def test_encryption_none
    run_generator ["--encryption=none"]
    if mongoid?
      assert_file "app/models/ahoy/message.rb"
    else
      assert_migration "db/migrate/create_ahoy_messages.rb", /t.string :to, index: true/
    end
  end

  def test_primary_key_type
    skip if mongoid?
    Rails.configuration.generators.stub(:options, {active_record: {primary_key_type: :uuid}}) do
      run_generator ["--encryption=lockbox"]
    end
    assert_migration "db/migrate/create_ahoy_messages.rb", /id: :uuid/
    assert_migration "db/migrate/create_ahoy_messages.rb", /type: :uuid/
  end
end
