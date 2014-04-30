module AhoyEmail
  class Interceptor
    class << self

      def delivering_email(message)
        AhoyEmail::Processor.new(message).track_send
      end

    end
  end
end
