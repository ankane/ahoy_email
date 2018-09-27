module AhoyEmail
  class Interceptor
    class << self
      def delivering_email(message)
        AhoyEmail::Tracker.new.perform(message)
      end
    end
  end
end
