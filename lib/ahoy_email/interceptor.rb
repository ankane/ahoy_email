module AhoyEmail
  class Interceptor
    class << self
      def delivering_email(message)
        AhoyEmail::Processor.new.process_message(message)
      end
    end
  end
end
