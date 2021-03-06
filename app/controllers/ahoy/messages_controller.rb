module Ahoy
  class MessagesController < ApplicationController
    filters = _process_action_callbacks.map(&:filter) - AhoyEmail.preserve_callbacks
    skip_before_action(*filters, raise: false)
    skip_after_action(*filters, raise: false)
    skip_around_action(*filters, raise: false)

    # legacy
    def open
      send_data Base64.decode64("R0lGODlhAQABAPAAAAAAAAAAACH5BAEAAAAALAAAAAABAAEAAAICRAEAOw=="), type: "image/gif", disposition: "inline"
    end

    def click
      if params[:id]
        # legacy
        token = params[:id].to_s
        url = params[:url].to_s
        signature = params[:signature].to_s
        expected_signature = OpenSSL::HMAC.hexdigest("SHA1", AhoyEmail::Utils.secret_token, url)
      else
        token = params[:t].to_s
        campaign = params[:c].to_s
        url = params[:u].to_s
        signature = params[:s].to_s
        expected_signature = AhoyEmail::Utils.signature(token: token, campaign: campaign, url: url)
      end

      if ActiveSupport::SecurityUtils.secure_compare(signature, expected_signature)
        data = {}
        data[:campaign] = campaign if campaign
        data[:token] = token
        data[:url] = url
        data[:controller] = self
        AhoyEmail::Utils.publish(:click, data)

        redirect_to url
      else
        if AhoyEmail.invalid_redirect_url
          redirect_to AhoyEmail.invalid_redirect_url
        else
          render plain: "Link expired", status: :not_found
        end
      end
    end
  end
end
