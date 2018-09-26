module AhoyEmail
  module Mailer
    extend ActiveSupport::Concern

    included do
      attr_accessor :ahoy_options
      after_action :save_ahoy_options
    end

    class_methods do
      def track(**options)
        before_action(options.slice(:only, :except)) do
          self.ahoy_options ||= AhoyEmail.default_options
          self.ahoy_options = ahoy_options.merge(options.except(:only, :except))
        end
      end

      def disable_track(**options)
        before_action(options) do
          @ahoy_disable_track = true
        end
      end
    end

    def save_ahoy_options
      ahoy_options = self.ahoy_options || AhoyEmail.default_options

      # TODO figure out how to enable/disable
      if ahoy_options && !@ahoy_disable_track
        options = {}
        ahoy_options.each do |k, v|
          # execute options in mailer content
          options[k] = v.respond_to?(:call) ? instance_exec(&v) : v
        end
        AhoyEmail::Processor.new.save_options(self, options)
      end
    end
  end
end
