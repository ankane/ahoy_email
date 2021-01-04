module Ahoy
  class MessagesController < ApplicationController
    filters = _process_action_callbacks.map(&:filter) - AhoyEmail.preserve_callbacks
    skip_before_action(*filters, raise: false)
    skip_after_action(*filters, raise: false)
    skip_around_action(*filters, raise: false)

    before_action :set_message

    def open
      if @message && !@message.opened_at
        @message.opened_at = Time.now
        @message.save!
      end

      publish :open

      send_data Base64.decode64("R0lGODlhAQABAPAAAAAAAAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw=="), type: "image/gif", disposition: "inline"
    end

    def click
      if @message && !@message.clicked_at
        @message.clicked_at = Time.now
        @message.opened_at ||= @message.clicked_at if @message.respond_to?(:opened_at=)
        @message.save!
      end

      user_signature = params[:signature].to_s
      url = params[:url].to_s

      # TODO sign more than just url and transition to HMAC-SHA256
      digest = "SHA1"
      signature = OpenSSL::HMAC.hexdigest(digest, AhoyEmail.secret_token, url)

      if ActiveSupport::SecurityUtils.secure_compare(user_signature, signature)
        publish :click, url: params[:url]

        redirect_to url
      else
        redirect_to AhoyEmail.invalid_redirect_url || main_app.root_url
      end
    end

    protected

    def set_message
      model = AhoyEmail.message_model

      return if model.respond_to?(:column_names) && !model.column_names.include?("token")

      @message = model.where(token: params[:id]).first
    end

    def publish(name, event = {})
      AhoyEmail.subscribers.each do |subscriber|
        subscriber = subscriber.new if subscriber.is_a?(Class) && !subscriber.respond_to?(name)
        if subscriber.respond_to?(name)
          event[:message] = @message
          event[:controller] = self
          subscriber.send name, event
        end
      end
    end
  end
end
