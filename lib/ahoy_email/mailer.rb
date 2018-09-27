module AhoyEmail
  module Mailer
    extend ActiveSupport::Concern

    included do
      attr_writer :ahoy_options
      after_action :save_ahoy_options
    end

    class_methods do
      def track(**options)
        before_action(options.slice(:only, :except)) do
          self.ahoy_options = ahoy_options.merge(message: true).merge(options.except(:only, :except))
        end
      end
    end

    def track(**options)
      self.ahoy_options = ahoy_options.merge(message: true).merge(options)
    end

    def ahoy_options
      @ahoy_options ||= AhoyEmail.default_options
    end

    def save_ahoy_options
      ahoy_options = self.ahoy_options

      if ahoy_options[:message]
        options = {}
        ahoy_options.each do |k, v|
          # execute options in mailer content
          options[k] = v.respond_to?(:call) ? instance_exec(&v) : v
        end
        AhoyEmail::Processor.new.perform(self, options)
      end
    end
  end
end
