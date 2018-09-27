module AhoyEmail
  class Tracker
    attr_reader :message

    def initialize(message)
      @message = message
    end

    def perform
      Safely.safely do
        if message.perform_deliveries && message.ahoy_options
          data = message.ahoy_options.merge(message: message)
          message.ahoy_message = AhoyEmail.track_method.call(data)
        end
      end
    end
  end
end
