ActiveRecord::Schema.define do
  create_table :ahoy_messages, force: true do |t|
    t.references :user, polymorphic: true
    t.text :to
    t.string :mailer
    t.text :subject
    t.timestamp :sent_at

    # extra
    t.integer :coupon_id
  end

  create_table :users, force: true do |t|
    t.string :email
  end
end
