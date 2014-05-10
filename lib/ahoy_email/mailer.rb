module AhoyEmail
  module Mailer

    def self.included(base)
      base.extend ClassMethods
      base.class_eval do
        class_attribute :ahoy_options
        self.ahoy_options = {}
        alias_method_chain :mail, :ahoy
      end
    end

    module ClassMethods
      def track(options)
        self.ahoy_options = ahoy_options.merge(message: true).merge(options)
      end
    end

    def track(options)
      @ahoy_options = (@ahoy_options || {}).merge(message: true).merge(options)
    end

    def mail_with_ahoy(headers = {}, &block)
      message = mail_without_ahoy(headers, &block)

      options = AhoyEmail.options.merge(self.class.ahoy_options).merge(@ahoy_options || {})
      options.each do |k, v|
        if v.respond_to?(:call)
          options[k] = v.call(message, self)
        end
      end
      AhoyEmail::Processor.new(message, options).process

      message
    end

  end
end
