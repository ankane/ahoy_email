module AhoyEmail
  class Interceptor
    # include ActionView::Helpers::AssetTagHelper

    def self.delivering_email(message)
      # body = (message.html_part || message).body.raw_source
      # p AhoyEmail::Engine.routes
      # if body
      #   regex = /<\/body>/i
      #   pixel = image_tag(AhoyEmail::Engine.routes.url_helpers.url_for(controller: "messages", action: "open"))
      #   if body.match(regex)
      #     body.gsub!(regex, "#{pixel}\\0")
      #   else
      #     body << pixel
      #   end
      # end
      Ahoy::Message.create!(
        subject: message.subject,
        content: message.to_s
      )
    end

  end
end
