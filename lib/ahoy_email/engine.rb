module AhoyEmail
  class Engine < ::Rails::Engine

    initializer "ahoy_email" do |app|
      AhoyEmail.secret_token = app.config.try(:secret_key_base) || app.config.try(:secret_token)
    end

  end
end
