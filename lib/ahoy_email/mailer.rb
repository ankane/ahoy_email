module AhoyEmail
  module Mailer
    extend ActiveSupport::Concern

    included do
      attr_accessor :ahoy_options
      class_attribute :ahoy_options
      self.ahoy_options = {}
      after_action :track_ahoy_message
    end

    class_methods do
      def track(options = {})
        self.ahoy_options = ahoy_options.merge(message: true).merge(options)
      end
    end

    def track(options = {})
      self.ahoy_options = (ahoy_options || {}).merge(message: true).merge(options)
    end

    def track_ahoy_message
      AhoyEmail::Processor.new.process_message(message, self)
    end
  end
end
