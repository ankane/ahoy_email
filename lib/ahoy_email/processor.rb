module AhoyEmail
  class Processor
    include ActionView::Helpers::AssetTagHelper

    attr_reader :message, :options, :ahoy_message

    def initialize(message, options = {})
      @message = message
      @options = options
    end

    def process
      if options[:message]
        @ahoy_message = AhoyEmail.message_model.new
        ahoy_message.token = generate_token
        ahoy_message.user = options[:user]

        track_utm_parameters if options[:utm_params]
        track_open if options[:open]
        track_click if options[:click]

        # save
        ahoy_message.subject = message.subject if ahoy_message.respond_to?(:subject=)
        ahoy_message.content = message.to_s if ahoy_message.respond_to?(:content=)
        ahoy_message.save
        message["Ahoy-Message-Id"] = ahoy_message.id
      end
    rescue => e
      report_error(e)
    end

    def track_send
      if (message_id = message["Ahoy-Message-Id"])
        ahoy_message = Ahoy::Message.where(id: message_id.to_s).first
        if ahoy_message
          ahoy_message.sent_at = Time.now
          ahoy_message.save
        end
        message["Ahoy-Message-Id"] = nil
      end
    rescue => e
      report_error(e)
    end

    protected

    def generate_token
      SecureRandom.urlsafe_base64(32).gsub(/[\-_]/, "").first(32)
    end

    def track_utm_parameters
      if html_part?
        body = (message.html_part || message).body

        doc = Nokogiri::HTML(body.raw_source)
        doc.css("a").each do |link|
          key = "data-disable-utm-params"
          if link[key]
            # remove attribute
            link.remove_attribute(key)
          else
            uri = Addressable::URI.parse(link["href"])
            params = uri.query_values || {}
            %w[utm_source utm_medium utm_term utm_content utm_campaign].each do |key|
              params[key] ||= options[key.to_sym] if options[key.to_sym]
            end
            uri.query_values = params
            link["href"] = uri.to_s
          end
        end

        # hacky
        body.raw_source.sub!(body.raw_source, doc.to_s)
      end
    end

    def track_open
      if html_part?
        raw_source = (message.html_part || message).body.raw_source
        regex = /<\/body>/i
        url =
          AhoyEmail::Engine.routes.url_helpers.url_for(
            Rails.application.config.action_mailer.default_url_options.merge(
              controller: "ahoy/messages",
              action: "open",
              id: ahoy_message.token,
              format: "gif"
            )
          )
        pixel = image_tag(url, size: "1x1", alt: nil)

        # try to add before body tag
        if raw_source.match(regex)
          raw_source.gsub!(regex, "#{pixel}\\0")
        else
          raw_source << pixel
        end
      end
    end

    def track_click
      if html_part?
        body = (message.html_part || message).body

        doc = Nokogiri::HTML(body.raw_source)
        doc.css("a").each do |link|
          key = "data-disable-tracking"
          if link[key]
            # remove attribute
            link.remove_attribute(key)
          else
            signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::Digest.new("sha1"), AhoyEmail.secret_token, link["href"])
            url =
              AhoyEmail::Engine.routes.url_helpers.url_for(
                Rails.application.config.action_mailer.default_url_options.merge(
                  controller: "ahoy/messages",
                  action: "click",
                  id: ahoy_message.token,
                  url: link["href"],
                  signature: signature
                )
              )

            link["href"] = url
          end
        end

        # hacky
        body.raw_source.sub!(body.raw_source, doc.to_s)
      end
    end

    def html_part?
      (message.html_part || message).content_type =~ /html/
    end

    # not a fan of quiet errors
    # but tracking should *not* break
    # email delivery in production
    def report_error(e)
      if Rails.env.production?
        $stderr.puts e
      else
        raise e
      end
    end

  end
end