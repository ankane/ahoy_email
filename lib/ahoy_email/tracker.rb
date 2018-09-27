module AhoyEmail
  class Tracker
    attr_reader :message

    def initialize(message)
      @message = message
    end

    def perform
      Safely.safely do
        # perform_deliveries check still needed in observer
        if message.perform_deliveries && message.ahoy_data
          data = message.ahoy_data.merge(message: message)
          message.ahoy_message = AhoyEmail.track_method.call(data)
        end
      end
    end
  end
end
