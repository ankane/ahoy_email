module AhoyEmail
  class Interceptor
    class << self
      def delivering_email(message)
        AhoyEmail::Tracker.new(message).perform
      end
    end
  end
end
