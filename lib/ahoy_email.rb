require "ahoy_email/version"
require "action_mailer"
require "nokogiri"
require "addressable/uri"
require "ahoy_email/interceptor"
require "ahoy_email/engine"

ActionMailer::Base.register_interceptor AhoyEmail::Interceptor

module ActionMailer
  class Base

    def mail_with_ahoy(headers = {}, &block)
      user = headers.delete(:user)
      if user
        self.headers["Ahoy-User-Id"] = user.id
        self.headers["Ahoy-User-Type"] = user.class
      end
      mail_without_ahoy(headers, &block)
    end
    alias_method_chain :mail, :ahoy

  end
end
