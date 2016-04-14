require "ahoy_email/version"
require "action_mailer"
require "rails"
require "nokogiri"
require "addressable/uri"
require "openssl"
require "safely_block"
require "ahoy_email/processor"
require "ahoy_email/interceptor"
require "ahoy_email/mailer"
require "ahoy_email/engine"

module AhoyEmail
  mattr_accessor :secret_token, :options, :subscribers

  self.options = {
    message: true,
    open: true,
    click: true,
    utm_params: true,
    utm_source: proc { |message, mailer| mailer.mailer_name },
    utm_medium: "email",
    utm_term: nil,
    utm_content: nil,
    utm_campaign: proc { |message, mailer| mailer.action_name },
    user: proc { |message, mailer| (message.to.size == 1 ? User.where(email: message.to.first).first : nil) rescue nil },
    mailer: proc { |message, mailer| "#{mailer.class.name}##{mailer.action_name}" },
    url_options: {}
  }

  self.subscribers = []

  def self.track(options)
    self.options = self.options.merge(options)
  end

  class << self
    attr_writer :message_model
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :s3_access_key, :s3_secret_key, :s3_bucket_name, :s3_region, :s3_path

    def initialize
      @s3_access_key = nil
      @s3_secret_key = nil
      @s3_bucket_name = nil
      @s3_region = nil
      @s3_path = "emails/%Y/%m/%d"
    end
  end

  def self.message_model
    @message_model || Ahoy::Message
  end
end

ActionMailer::Base.send :include, AhoyEmail::Mailer
ActionMailer::Base.register_interceptor AhoyEmail::Interceptor
