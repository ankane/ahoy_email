module AhoyEmail
  module Mailer
    extend ActiveSupport::Concern

    included do
      attr_accessor :ahoy_options
      class_attribute :ahoy_options
      self.ahoy_options = {}
      after_action :save_ahoy_options
    end

    class_methods do
      def track(options = {})
        self.ahoy_options = ahoy_options.merge(message: true).merge(options)
      end
    end

    def track(options = {})
      self.ahoy_options = (ahoy_options || {}).merge(message: true).merge(options)
    end

    def save_ahoy_options
      AhoyEmail::Processor.new.save_options(message, self)
    end
  end
end
