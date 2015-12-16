module AhoyEmail
  module Mailer
    def self.included(base)
      base.extend ClassMethods
      base.class_eval do
        attr_accessor :ahoy_options
        class_attribute :ahoy_options
        self.ahoy_options = {}
        alias_method_chain :mail, :ahoy
      end
    end

    module ClassMethods
      def track(options = {})
        self.ahoy_options = ahoy_options.merge(message: true).merge(options)
      end
    end

    def track(options = {})
      self.ahoy_options = (ahoy_options || {}).merge(message: true).merge(options)
    end

    def mail_with_ahoy(headers = {}, &block)
      # this mimics what original method does
      return message if @_mail_was_called && headers.blank? && !block

      message = mail_without_ahoy(headers, &block)
      AhoyEmail::Processor.new(message, self).process
      message
    end
  end
end
