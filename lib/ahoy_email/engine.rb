module AhoyEmail
  class Engine < ::Rails::Engine

    initializer "ahoy_email" do |app|
      AhoyEmail.secret_token = app.config.respond_to?(:secret_key_base) ? app.config.secret_key_base : app.config.secret_token
    end

  end
end
