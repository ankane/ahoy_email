module AhoyEmail
  class Tracker
    def perform(message)
      Safely.safely do
        if message.perform_deliveries && (data_header = message["Ahoy-Message"])
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
