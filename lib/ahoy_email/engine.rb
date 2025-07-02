require "rails/engine"

module AhoyEmail
  class Engine < ::Rails::Engine
    initializer "ahoy_email" do |app|
      AhoyEmail.secret_token ||= app.key_generator.generate_key("ahoy_email")
    end
  end
end
