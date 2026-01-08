require "rails/engine"

module AhoyEmail
  class Engine < ::Rails::Engine
    initializer "ahoy_email" do |app|
      # avoid app.key_generator due to https://github.com/ankane/ahoy_email/pull/168
      AhoyEmail.secret_token ||= ActiveSupport::KeyGenerator.new(app.secret_key_base, iterations: 1000, hash_digest_class: OpenSSL::Digest::SHA1).generate_key("ahoy_email")
    end
  end
end
