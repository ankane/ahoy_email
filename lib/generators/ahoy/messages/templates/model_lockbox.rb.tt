class Ahoy::Message < ActiveRecord::Base
  self.table_name = "ahoy_messages"

  belongs_to :user, polymorphic: true, optional: true

  has_encrypted :to
  blind_index :to
end
