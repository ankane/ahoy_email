module AhoyEmail
  class Processor
    attr_reader :message, :mailer, :ahoy_message

    def initialize(message, mailer = nil)
      @message = message
      @mailer = mailer
    end

    def process
      action_name = mailer.action_name.to_sym
      if options[:message] and (!options[:only] or options[:only].include?(action_name)) and !options[:except].to_a.include?(action_name)
        @ahoy_message = AhoyEmail.message_model.new
        ahoy_message.token = generate_token
        ahoy_message.to = message.to.join(", ") if ahoy_message.respond_to?(:to=)
        ahoy_message.user = options[:user]

        track_open if options[:open]
        track_links if options[:utm_params] or options[:click]

        ahoy_message.mailer = options[:mailer] if ahoy_message.respond_to?(:mailer=)
        ahoy_message.subject = message.subject if ahoy_message.respond_to?(:subject=)
        
        if ahoy_message.respond_to?(:content=)
          ahoy_message.content = message.header.encoded
          ahoy_message.content << "\r\n"
          if message.html_part
            ahoy_message.content << message.html_part.body.encoded
          elsif message.multipart?
            ahoy_message.content << message.text_part ? message.text_part.body.encoded : nil
          else
            ahoy_message.content << message.body.encoded
          end
        end


        ahoy_message.save
        message["Ahoy-Message-Id"] = ahoy_message.id.to_s
      end
    rescue => e
      report_error(e)
    end

    def track_send
      if (message_id = message["Ahoy-Message-Id"])
        ahoy_message = AhoyEmail.message_model.where(id: message_id.to_s).first
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

    def options
      @options ||= begin
        options = AhoyEmail.options.merge(mailer.class.ahoy_options)
        if mailer.ahoy_options
          options = options.except(:only, :except).merge(mailer.ahoy_options)
        end
        options.each do |k, v|
          if v.respond_to?(:call)
            options[k] = v.call(message, mailer)
          end
        end
        options
      end
    end

    def generate_token
      SecureRandom.urlsafe_base64(32).gsub(/[\-_]/, "").first(32)
    end

    def track_open
      if html_part?
        raw_source = (message.html_part || message).body.raw_source
        regex = /<\/body>/i
        url =
          url_for(
            controller: "ahoy/messages",
            action: "open",
            id: ahoy_message.token,
            format: "gif"
          )
        pixel = ActionController::Base.helpers.image_tag(url, size: "1x1", alt: nil)

        # try to add before body tag
        if raw_source.match(regex)
          raw_source.gsub!(regex, "#{pixel}\\0")
        else
          raw_source << pixel
        end
      end
    end

    def track_links
      if html_part?
        body = (message.html_part || message).body

        doc = Nokogiri::HTML(body.raw_source)
        doc.css("a[href]").each do |link|
          # utm params first
          if options[:utm_params] and !skip_attribute?(link, "utm-params")
            uri = Addressable::URI.parse(link["href"])
            params = uri.query_values || {}
            %w[utm_source utm_medium utm_term utm_content utm_campaign].each do |key|
              params[key] ||= options[key.to_sym] if options[key.to_sym]
            end
            uri.query_values = params
            link["href"] = uri.to_s
          end

          if options[:click] and !skip_attribute?(link, "click")
            signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha1"), AhoyEmail.secret_token, link["href"])
            link["href"] =
              url_for(
                controller: "ahoy/messages",
                action: "click",
                id: ahoy_message.token,
                url: link["href"],
                signature: signature
              )
          end
        end

        # hacky
        body.raw_source.sub!(body.raw_source, doc.to_s)
      end
    end

    def html_part?
      (message.html_part || message).content_type =~ /html/
    end

    def skip_attribute?(link, suffix)
      attribute = "data-skip-#{suffix}"
      if link[attribute]
        # remove it
        link.remove_attribute(attribute)
        true
      elsif link["href"].to_s =~ /unsubscribe/i
        # try to avoid unsubscribe links
        true
      else
        false
      end
    end

    def url_for(options)
      AhoyEmail::Engine.routes.url_helpers.url_for((ActionMailer::Base.default_url_options || {}).merge(options))
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
