require "rails/generators"

module Ahoy
  module Generators
    class ClicksGenerator < Rails::Generators::Base
      def copy_templates
        invoke "ahoy:clicks:activerecord"
      end
    end
  end
end
