module Ahoy
  class MessagesController < ActionController::Base
    before_filter :set_message

    def open
      if @message and !@message.opened_at
        @message.opened_at = Time.now
        @message.save!
      end
      send_data Base64.decode64("R0lGODlhAQABAPAAAAAAAAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw=="), type: "image/gif", disposition: "inline"
    end

    def click
      if @message and !@message.clicked_at
        @message.clicked_at = Time.now
        @message.save!
      end
      url = params[:url]
      signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest::Digest.new("sha1"), AhoyEmail.secret_token, url)
      if params[:signature] == signature
        redirect_to url
      else
        redirect_to main_app.root_url
      end
    end

    protected

    def set_message
      @message = AhoyEmail.message_model.where(token: params[:id]).first
    end

  end
end
