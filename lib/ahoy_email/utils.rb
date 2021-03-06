module AhoyEmail
  class Utils
    OPTION_KEYS = {
      message: %i(message mailer user extra),
      utm_params: %i(utm_source utm_medium utm_term utm_content utm_campaign),
      click: %i(campaign url_options unsubscribe_links)
    }

    class << self
      def signature(token:, campaign:, url:)
        # encode and join with a character outside encoding
        data = [token, campaign, url].map { |v| Base64.strict_encode64(v.to_s) }.join("|")

        Base64.urlsafe_encode64(OpenSSL::HMAC.digest("SHA256", secret_token, data), padding: false)
      end

      def publish(name, event)
        method_name = "track_#{name}"
        AhoyEmail.subscribers.each do |subscriber|
          subscriber = subscriber.new if subscriber.is_a?(Class)
          if subscriber.respond_to?(method_name)
            subscriber.send(method_name, event.dup)
          elsif name == :click && subscriber.respond_to?(:click)
            # legacy
            subscriber.send(:click, event.dup)
          end
        end
      end

      def secret_token
        AhoyEmail.secret_token || (raise "Secret token is empty")
      end
    end
  end
end
