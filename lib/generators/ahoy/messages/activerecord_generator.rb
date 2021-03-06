require "rails/generators/active_record"

module Ahoy
  module Generators
    module Messages
      class ActiverecordGenerator < Rails::Generators::Base
        include ActiveRecord::Generators::Migration
        source_root File.join(__dir__, "templates")

        class_option :unencrypted, type: :boolean

        def copy_migration
          migration_template "migration.rb", "db/migrate/create_ahoy_messages.rb", migration_version: migration_version
        end

        def copy_template
          if encrypted?
            template "model_encrypted.rb", "app/models/ahoy/message.rb"
          end
        end

        def migration_version
          "[#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}]"
        end

        def to_column
          if encrypted?
            "t.text :to_ciphertext\n      t.string :to_bidx, index: true"
          else
            "t.string :to, index: true"
          end
        end

        def encrypted?
          !options[:unencrypted]
        end
      end
    end
  end
end
