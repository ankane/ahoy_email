module AhoyEmail
  class Engine < ::Rails::Engine

    initializer "ahoy_email" do |app|
      secrets = app.respond_to?(:secrets) ? app.secrets : app.config
      AhoyEmail.secret_token ||= secrets.respond_to?(:secret_key_base) ? secrets.secret_key_base : secrets.secret_token
    end

  end
end
