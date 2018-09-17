module AhoyEmail
  module Mailer
    def self.included(base)
      base.extend ClassMethods
      base.prepend InstanceMethods
      base.class_eval do
        attr_accessor :ahoy_options
        class_attribute :ahoy_options
        self.ahoy_options = { message: true }
      end
    end

    module ClassMethods
      def track(options = {})
        self.ahoy_options = ahoy_options.merge(options)
      end
    end

    module InstanceMethods
      def track(options = {})
        self.ahoy_options = (ahoy_options || {}).merge(options)
      end

      def mail(headers = {}, &block)
        # this mimics what original method does
        return message if @_mail_was_called && headers.blank? && !block

        message = super
        AhoyEmail::Processor.new(message, self).process
        message
      end
    end
  end
end
