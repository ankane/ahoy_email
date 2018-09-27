module AhoyEmail
  class Processor
    attr_reader :message, :mailer

    UTM_PARAMETERS = %w(utm_source utm_medium utm_term utm_content utm_campaign)

    def save_options(mailer, options)
      Safely.safely do
        action_name = mailer.action_name.to_sym
        data = {
          mailer: options[:mailer],
          extra: options[:extra]
        }
        user = options[:user]
        if user
          data[:user_type] = user.model_name.name
          data[:user_id] = user.id
        end
        # puts data.to_json
        mailer.message["Ahoy-Message"] = data.to_json
      end
    end

    def process_message(message)
      Safely.safely do
        if message.perform_deliveries && (data_header = message["Ahoy-Message"])
          data = JSON.parse(data_header.to_s).symbolize_keys
          data[:message] = message
          AhoyEmail.track_method.call(data)
        end
      end
    ensure
      message["Ahoy-Message"] = nil if message["Ahoy-Message"]
    end

    protected

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
