require "rails/engine"

module AhoyEmail
  class Engine < ::Rails::Engine
    initializer "ahoy_email", after: :load_config_initializers do |app|
      app.config.after_initialize do
        AhoyEmail.secret_token ||= app.key_generator.generate_key("ahoy_email")
      end
    end
  end
end
