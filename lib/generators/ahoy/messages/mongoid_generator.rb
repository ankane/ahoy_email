require "rails/generators"

module Ahoy
  module Generators
    module Messages
      class MongoidGenerator < Rails::Generators::Base
        source_root File.join(__dir__, "templates")

        class_option :unencrypted, type: :boolean

        def copy_templates
          if options[:unencrypted]
            template "mongoid.rb", "app/models/ahoy/message.rb"
          else
            template "mongoid_encrypted.rb", "app/models/ahoy/message.rb"
          end
        end
      end
    end
  end
end
