module Ahoy
  class Message < ActiveRecord::Base
    self.table_name = "ahoy_messages"
  end
end
