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
    message: true,
    open: true,
    click: true,
    utm_source: nil,
    utm_medium: "email",
    utm_term: nil,
    utm_content: nil,
    utm_campaign: nil
  }
end

module ActionMailer
  class Base
    class_attribute :ahoy_options
    self.ahoy_options = {}

    class << self
      def track(options)
        self.ahoy_options = ahoy_options.merge(options)
      end
    end

    def track(options)
      @ahoy_options = (@ahoy_options || {}).merge(options)
    end

    def mail_with_ahoy(headers = {}, &block)
      message = mail_without_ahoy(headers, &block)

      options = AhoyEmail.options.merge(self.class.ahoy_options).merge(@ahoy_options || {})
      AhoyEmail::Processor.new(message, options).process!

      message
    end
    alias_method_chain :mail, :ahoy

  end
end
