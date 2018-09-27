module AhoyEmail
  class Observer
    class << self
      def delivered_email(message)
        AhoyEmail::Tracker.new(message).perform
      end
    end
  end
end
