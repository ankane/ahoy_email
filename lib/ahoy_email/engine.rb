require "rails/engine"

module AhoyEmail
  class Engine < ::Rails::Engine
    initializer "ahoy_email" do |app|
      # default to secrets to keep backward compatible
      ActiveSupport::Deprecation.silence do
        secrets = app.respond_to?(:secrets) ? app.secrets : app.config
        AhoyEmail.secret_token ||= secrets.respond_to?(:secret_key_base) ? secrets.secret_key_base : secrets.secret_token
      end

      AhoyEmail.belongs_to = {optional: true} if Rails::VERSION::MAJOR >= 5
    end
  end
end
