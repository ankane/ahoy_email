require "rails/engine"

module AhoyEmail
  class Engine < ::Rails::Engine
    initializer "ahoy_email" do |app|
      AhoyEmail.secret_token ||= begin
        # Fix for issue with Mailkick and SECRET_KEY_BASE_DUMMY with Rails 7.1
        # https://github.com/ankane/mailkick/pull/74
        if Rails::VERSION::STRING.to_f >= 7.1 && ENV["SECRET_KEY_BASE_DUMMY"]
          # TODO use for token in 3.0
          app.key_generator.generate_key("ahoy_email")
        end

        # TODO remove in 3.0
        creds =
          if app.respond_to?(:credentials) && app.credentials.secret_key_base
            app.credentials
          elsif app.respond_to?(:secrets)
            app.secrets
          else
            app.config
          end

        token = creds.respond_to?(:secret_key_base) ? creds.secret_key_base : creds.secret_token
        token ||= app.secret_key_base # should come first, but need to maintain backward compatibility
        token
      end
    end
  end
end
