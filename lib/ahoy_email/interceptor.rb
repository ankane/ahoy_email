module AhoyEmail
  class Interceptor
    class << self

      def delivering_email(message)
        AhoyEmail::Processor.new(message).mark_sent!
      end

    end
  end
end
