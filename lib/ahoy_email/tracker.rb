module AhoyEmail
  class Tracker
    attr_reader :message

    def initialize(message)
      @message = message
    end

    def perform
      if message.perform_deliveries && (data_header = message["Ahoy-Message"])
        Safely.safely do
          data = JSON.parse(data_header.to_s).symbolize_keys
          data[:message] = message
          AhoyEmail.track_method.call(data)
        end
      end
    ensure
      message["Ahoy-Message"] = nil if message["Ahoy-Message"]
    end
  end
end
