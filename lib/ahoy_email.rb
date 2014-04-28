require "ahoy_email/version"
require "action_mailer"
require "ahoy_email/interceptor"
require "ahoy_email/engine"

ActionMailer::Base.register_interceptor AhoyEmail::Interceptor
