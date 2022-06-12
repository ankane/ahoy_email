class User
  include Mongoid::Document

  field :email, type: String
end
