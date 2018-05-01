module AhoyEmail
  class Processor
    attr_reader :message, :mailer

    UTM_PARAMETERS = %w(utm_source utm_medium utm_term utm_content utm_campaign)

    def initialize(message, mailer = nil)
      @message = message
      @mailer = mailer
    end

    def process
      Safely.safely do
        action_name = mailer.action_name.to_sym
        if options[:message] && (!options[:only] || options[:only].include?(action_name)) && !options[:except].to_a.include?(action_name)
          track_open if options[:open]
          track_links if options[:utm_params] || options[:click]

          data = {
            token: token
          }

          (%w(user mailer extra) + UTM_PARAMETERS).each do |k|
            data[k.to_sym] = options[k.to_sym]
          end

          AhoyEmail.track_method.call(message, data)
        end
      end
    end

    def track_send
      Safely.safely do
        if (message_id = message["Ahoy-Message-Id"]) && message.perform_deliveries
          ahoy_message = AhoyEmail.message_model.where(id: message_id.to_s).first
          if ahoy_message
            ahoy_message.sent_at = Time.now
            ahoy_message.save
          end
          message["Ahoy-Message-Id"] = nil
        end
      end
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

    def token
      @token ||= SecureRandom.urlsafe_base64(32).gsub(/[\-_]/, "").first(32)
    end

    def track_open
      if html_part?
        raw_source = (message.html_part || message).body.raw_source
        regex = /<\/body>/i
        url =
          url_for(
            controller: "ahoy/messages",
            action: "open",
            id: token,
            format: "gif"
          )
        pixel = ActionController::Base.helpers.image_tag(url, size: "1x1", alt: "")

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
          uri = parse_uri(link["href"])
          next unless trackable?(uri)
          # utm params first
          if options[:utm_params] && !skip_attribute?(link, "utm-params")
            params = uri.query_values(Array) || []
            UTM_PARAMETERS.each do |key|
              next if params.any? { |k, _v| k == key } || !options[key.to_sym]
              params << [key, options[key.to_sym]]
            end
            uri.query_values = params
            link["href"] = uri.to_s
          end

          if options[:click] && !skip_attribute?(link, "click")
            signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new("sha1"), AhoyEmail.secret_token, link["href"])
            link["href"] =
              url_for(
                controller: "ahoy/messages",
                action: "click",
                id: token,
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
      elsif link["href"].to_s =~ /unsubscribe/i && !options[:unsubscribe_links]
        # try to avoid unsubscribe links
        true
      else
        false
      end
    end

    # Filter trackable URIs, i.e. absolute one with http
    def trackable?(uri)
      uri && uri.absolute? && %w(http https).include?(uri.scheme)
    end

    # Parse href attribute
    # Return uri if valid, nil otherwise
    def parse_uri(href)
      # to_s prevent to return nil from this method
      if options[:heuristic_parse]
        Addressable::URI.heuristic_parse(href.to_s) rescue nil
      else
        Addressable::URI.parse(href.to_s) rescue nil
      end
    end

    def url_for(opt)
      opt = (ActionMailer::Base.default_url_options || {})
            .merge(options[:url_options])
            .merge(opt)
      AhoyEmail::Engine.routes.url_helpers.url_for(opt)
    end
  end
end
