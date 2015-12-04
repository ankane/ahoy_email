module Ahoy
  class Message < ActiveRecord::Base
    self.table_name = "ahoy_messages"

    belongs_to :user, polymorphic: true

    serialize :data, Hash
  end
end
