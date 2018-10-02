ActiveRecord::Schema.define do
  create_table :ahoy_messages, force: true do |t|
    t.references :user, polymorphic: true
    t.text :to
    t.string :mailer
    t.text :subject
    t.timestamp :sent_at

    # extra
    t.integer :coupon_id

    # legacy
    t.string :utm_source
    t.string :utm_medium
    t.string :utm_term
    t.string :utm_content
    t.string :utm_campaign
  end

  create_table :users, force: true do |t|
    t.string :email
  end
end
