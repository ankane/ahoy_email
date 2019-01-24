module Ahoy
  class MessagesController < ApplicationController
    filters = _process_action_callbacks.map(&:filter) - AhoyEmail.preserve_callbacks
    if Rails::VERSION::MAJOR >= 5
      skip_before_action(*filters, raise: false)
      skip_after_action(*filters, raise: false)
      skip_around_action(*filters, raise: false)
    else
      skip_action_callback *filters
    end

    def open

      message.where(opened_at: nil).update_all(opened_at: now)

      publish :open

      send_data Base64.decode64("R0lGODlhAQABAPAAAAAAAAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw=="), type: "image/gif", disposition: "inline"
    end

    def click

      message.where(clicked_at: nil)
             .update_all("clicked_at='#{now}', opened_at=COALESCE(opened_at, '#{now}')")
            #  .update_all(clicked_at: now, opened_at: "coalesce(updated_at, '#{now}'")

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

    def message
      @message ||= AhoyEmail.message_model.where(token: params[:id])
    end

    def now
      @now ||= Time.now
    end

    def publish(name, event = {})
      AhoyEmail.subscribers.each do |subscriber|
        if subscriber.respond_to?(name)
          event[:message] = message.first
          event[:controller] = self
          subscriber.send name, event
        end
      end
    end
  end
end
