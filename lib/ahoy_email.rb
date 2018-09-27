# dependencies
require "active_support"
require "addressable/uri"
require "nokogiri"
require "openssl"
require "safely/core"

# modules
require "ahoy_email/processor"
require "ahoy_email/tracker"
require "ahoy_email/interceptor"
require "ahoy_email/mailer"
require "ahoy_email/engine"
require "ahoy_email/version"

module AhoyEmail
  mattr_accessor :secret_token, :default_options, :subscribers, :belongs_to, :invalid_redirect_url, :track_method, :api
  mattr_writer :message_model

  self.api = false

  self.default_options = {
    message: true,
    open: false,
    click: false,
    utm_params: false,
    utm_source: -> { mailer_name },
    utm_medium: "email",
    utm_term: nil,
    utm_content: nil,
    utm_campaign: -> { action_name },
    user: -> { (params && params[:user]) || (message.to.size == 1 ? (User.find_by(email: message.to.first) rescue nil) : nil) },
    mailer: -> { "#{self.class.name}##{action_name}" },
    url_options: {},
    heuristic_parse: false
  }

  self.track_method = lambda do |data|
    message = data[:message]
    ahoy_message = AhoyEmail.message_model.new
    ahoy_message.to = Array(message.to).join(", ") if ahoy_message.respond_to?(:to=)
    ahoy_message.user_type = data[:user_type]
    ahoy_message.user_id = data[:user_id]

    ahoy_message.mailer = data[:mailer] if ahoy_message.respond_to?(:mailer=)
    ahoy_message.subject = message.subject if ahoy_message.respond_to?(:subject=)
    ahoy_message.content = message.to_s if ahoy_message.respond_to?(:content=)

    AhoyEmail::Processor::UTM_PARAMETERS.each do |k|
      ahoy_message.send("#{k}=", data[k.to_sym]) if ahoy_message.respond_to?("#{k}=")
    end

    ahoy_message.assign_attributes(data[:extra] || {})

    ahoy_message.sent_at = Time.now
    ahoy_message.save!
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
  # if ActionMailer::Base.respond_to?(:register_preview_interceptor)
  #   ActionMailer::Base.register_preview_interceptor(AhoyEmail::Interceptor)
  # end
end
