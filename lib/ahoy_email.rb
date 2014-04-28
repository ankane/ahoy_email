require "ahoy_email/version"
require "action_mailer"
require "nokogiri"
require "addressable/uri"
require "ahoy_email/interceptor"
require "ahoy_email/engine"

ActionMailer::Base.register_interceptor AhoyEmail::Interceptor
