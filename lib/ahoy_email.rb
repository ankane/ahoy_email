# dependencies
require "active_support"
require "addressable/uri"
require "nokogiri"
require "openssl"
require "safely/core"

# modules
require "ahoy_email/processor"
require "ahoy_email/tracker"
require "ahoy_email/observer"
require "ahoy_email/mailer"
require "ahoy_email/version"
require "ahoy_email/engine" if defined?(Rails)

module AhoyEmail
  mattr_accessor :secret_token, :default_options, :subscribers, :invalid_redirect_url, :track_method, :api, :preserve_callbacks
  mattr_writer :message_model
  mattr_writer :message_parent_controller

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
    user: -> { @user || (respond_to?(:params) && params && params[:user]) || (message.to.size == 1 ? (User.find_by(email: message.to.first) rescue nil) : nil) },
    mailer: -> { "#{self.class.name}##{action_name}" },
    url_options: {},
    extra: {},
    unsubscribe_links: false
  }

  self.track_method = lambda do |data|
    message = data[:message]

    ahoy_message = AhoyEmail.message_model.new
    ahoy_message.to = Array(message.to).join(", ") if ahoy_message.respond_to?(:to=)
    ahoy_message.user = data[:user]

    ahoy_message.mailer = data[:mailer] if ahoy_message.respond_to?(:mailer=)
    ahoy_message.subject = message.subject if ahoy_message.respond_to?(:subject=)
    ahoy_message.content = message.encoded if ahoy_message.respond_to?(:content=)

    AhoyEmail::Processor::UTM_PARAMETERS.each do |k|
      ahoy_message.send("#{k}=", data[k.to_sym]) if ahoy_message.respond_to?("#{k}=")
    end
    
    ahoy_message.token = data[:token] if ahoy_message.respond_to?(:token=)

    ahoy_message.assign_attributes(data[:extra] || {})

    ahoy_message.sent_at = Time.now
    ahoy_message.save!

    ahoy_message
  end

  self.subscribers = []

  self.preserve_callbacks = []

  self.message_model = -> { ::Ahoy::Message }
  
  self.message_parent_controller = -> { ::ActionController::Base }

  def self.message_model
    model = defined?(@@message_model) && @@message_model
    model = model.call if model.respond_to?(:call)
    model
  end

  def self.message_parent_controller
    controller = defined?(@@message_parent_controller) && @@message_parent_controller
    controller = controller.call if controller.respond_to?(:call)
    controller
  end
end

ActiveSupport.on_load(:action_mailer) do
  include AhoyEmail::Mailer
  register_observer AhoyEmail::Observer
  Mail::Message.send(:attr_accessor, :ahoy_data, :ahoy_message)
end
