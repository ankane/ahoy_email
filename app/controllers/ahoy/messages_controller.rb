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
      # redirect
    end

    protected

    def set_message
      @message = Ahoy::Message.where(token: params[:token]).first
    end

  end
end
