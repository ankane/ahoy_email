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
    utm_params: true,
    utm_source: proc {|message, mailer| mailer.mailer_name },
    utm_medium: "email",
    utm_term: nil,
    utm_content: nil,
    utm_campaign: proc {|message, mailer| mailer.action_name },
    user: proc{|message, mailer| User.where(email: message.to.first).first rescue nil }
  }

  def self.message_model=(message_model)
    @message_model = message_model
  end

  def self.message_model
    @message_model || Ahoy::Message
  end

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
      options.each do |k, v|
        if v.respond_to?(:call)
          options[k] = v.call(message, self)
        end
      end
      AhoyEmail::Processor.new(message, options).process

      message
    end
    alias_method_chain :mail, :ahoy

  end
end
