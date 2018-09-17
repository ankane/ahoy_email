require "active_support"
require "addressable/uri"
require "nokogiri"
require "openssl"
require "safely/core"

require "ahoy_email/processor"
require "ahoy_email/interceptor"
require "ahoy_email/mailer"
require "ahoy_email/engine"
require "ahoy_email/version"

module AhoyEmail
  mattr_accessor :secret_token, :options, :subscribers, :belongs_to, :invalid_redirect_url, :track_method
  mattr_writer :message_model

  self.options = {
    message: true,
    open: true,
    click: true,
    utm_params: true,
    utm_source: ->(message, mailer) { mailer.mailer_name },
    utm_medium: "email",
    utm_term: nil,
    utm_content: nil,
    utm_campaign: ->(message, mailer) { mailer.action_name },
    user: ->(message, mailer) { (message.to.size == 1 ? User.where(email: message.to.first).first : nil) rescue nil },
    mailer: ->(message, mailer) { "#{mailer.class.name}##{mailer.action_name}" },
    url_options: {},
    heuristic_parse: false
  }

  self.track_method = lambda do |message, data|
    ahoy_message = AhoyEmail.message_model.new
    ahoy_message.token = data[:token]
    ahoy_message.to = Array(message.to).join(", ") if ahoy_message.respond_to?(:to=)
    ahoy_message.user = data[:user]

    ahoy_message.mailer = data[:mailer] if ahoy_message.respond_to?(:mailer=)
    ahoy_message.subject = message.subject if ahoy_message.respond_to?(:subject=)
    ahoy_message.content = message.to_s if ahoy_message.respond_to?(:content=)

    if options[:message] && options[:utm_params]
      AhoyEmail::Processor::UTM_PARAMETERS.each do |k|
        ahoy_message.send("#{k}=", data[k.to_sym]) if ahoy_message.respond_to?("#{k}=")
      end
    end

    ahoy_message.assign_attributes(data[:extra] || {})

    ahoy_message.save!
    message["Ahoy-Message-Id"] = ahoy_message.id.to_s
  end

  self.subscribers = []

  self.belongs_to = {}

  def self.track(options)
    self.options = self.options.merge(options)
  end

  def self.message_model
    model = (defined?(@message_model) && @message_model) || ::Ahoy::Message
    model = model.call if model.respond_to?(:call)
    model
  end
end

ActiveSupport.on_load(:action_mailer) do
  include AhoyEmail::Mailer
  register_interceptor AhoyEmail::Interceptor
end
