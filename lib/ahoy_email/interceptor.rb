module AhoyEmail
  class Interceptor
    class << self
      def delivering_email(message)
        AhoyEmail::Processor.new.track_message(message)
      end
    end
  end
end
