require "ahoy_email/version"
require "action_mailer"
require "nokogiri"
require "addressable/uri"
require "openssl"
require "ahoy_email/processor"
require "ahoy_email/interceptor"
require "ahoy_email/engine"

ActionMailer::Base.register_interceptor AhoyEmail::Interceptor

module AhoyEmail
  mattr_accessor :secret_token, :options

  self.options = {
    create_message: true,
    track_open: true,
    track_click: true,
    utm_source: nil,
    utm_medium: "email",
    utm_term: nil,
    utm_content: nil,
    utm_campaign: nil
  }
end

module ActionMailer
  class Base

    def mail_with_ahoy(headers = {}, &block)
      # https://github.com/rails/rails/blob/master/actionmailer/lib/action_mailer/base.rb#L754
      default_values = {}
      self.class.default.each do |k,v|
        default_values[k] = v.is_a?(Proc) ? instance_eval(&v) : v
      end

      options = headers[:ahoy] || {}
      options = options.reverse_merge(default_values[:ahoy] || {})
      options = options.reverse_merge(AhoyEmail.options)

      message =  mail_without_ahoy(headers, &block)

      # remove ahoy header
      message[:ahoy] = nil

      AhoyEmail::Processor.new(message, options).process!

      message
    end
    alias_method_chain :mail, :ahoy

  end
end
