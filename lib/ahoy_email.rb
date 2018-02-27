require "active_support"
require "nokogiri"
require "addressable/uri"
require "openssl"
require "safely/core"
require "ahoy_email/processor"
require "ahoy_email/interceptor"
require "ahoy_email/mailer"
require "ahoy_email/engine"
require "ahoy_email/version"

module AhoyEmail
  mattr_accessor :secret_token, :options, :subscribers, :belongs_to, :invalid_redirect_url

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

  self.belongs_to = {}

  def self.track(options)
    self.options = self.options.merge(options)
  end

  class << self
    attr_writer :message_model
  end

  def self.message_model
    (defined?(@message_model) && @message_model) || ::Ahoy::Message
  end
end

ActiveSupport.on_load(:action_mailer) do
  include AhoyEmail::Mailer
  register_interceptor AhoyEmail::Interceptor
end
