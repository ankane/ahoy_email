module Ahoy
  class Message < ActiveRecord::Base
    self.table_name = "ahoy_messages"

    belongs_to :user, (ActiveRecord::VERSION::MAJOR >= 5 ? {optional: true} : {}).merge(polymorphic: true)
  end
end
