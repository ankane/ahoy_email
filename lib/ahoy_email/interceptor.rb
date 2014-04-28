module AhoyEmail
  class Interceptor
    class << self
      include ActionView::Helpers::AssetTagHelper
    end

    def self.delivering_email(message)
      ahoy_message = Ahoy::Message.new
      ahoy_message.token = generate_token

      # add user
      track_user(message, ahoy_message)

      # track open
      track_open(message, ahoy_message)

      # TODO add UTM parameters

      # track click
      track_click(message, ahoy_message)

      # save
      ahoy_message.subject = message.subject if ahoy_message.respond_to?(:subject=)
      ahoy_message.content = message.to_s if ahoy_message.respond_to?(:content=)
      ahoy_message.sent_at = Time.now
      ahoy_message.save
    end

    def self.generate_token
      SecureRandom.urlsafe_base64(32).gsub(/[\-_]/, "").first(32)
    end

    def self.track_user(message, ahoy_message)
      ahoy_message.user_id = message["Ahoy-User-Id"].to_s.presence
      ahoy_message.user_type = message["Ahoy-User-Type"].to_s.presence

      # remove headers
      message["Ahoy-User-Id"] = nil
      message["Ahoy-User-Type"] = nil
    end

    def self.track_open(message, ahoy_message)
      if html_part?(message)
        raw_source = (message.html_part || message).body.raw_source
        regex = /<\/body>/i
        url =
          AhoyEmail::Engine.routes.url_helpers.url_for(
            Rails.application.config.action_mailer.default_url_options.merge(
              controller: "ahoy/messages",
              action: "open",
              token: ahoy_message.token,
              format: "gif"
            )
          )
        pixel = image_tag(url)

        # try to add before body tag
        if raw_source.match(regex)
          raw_source.gsub!(regex, "#{pixel}\\0")
        else
          raw_source << pixel
        end
      end
    end

    def self.track_click(message, ahoy_message)
      if html_part?(message)
        body = (message.html_part || message).body

        doc = Nokogiri::HTML(body.raw_source)
        doc.css("a").each do |link|
          url =
            AhoyEmail::Engine.routes.url_helpers.url_for(
              Rails.application.config.action_mailer.default_url_options.merge(
                controller: "ahoy/messages",
                action: "click",
                token: ahoy_message.token,
                url: link["href"]
              )
            )

          link["href"] = url
        end

        # hacky
        body.raw_source.sub!(body.raw_source, doc.to_s)
      end
    end

    def self.html_part?(message)
      (message.html_part || message).content_type =~ /html/
    end

  end
end
