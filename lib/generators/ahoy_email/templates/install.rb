class <%= migration_class_name %> < ActiveRecord::Migration
  def change
    create_table :ahoy_messages do |t|
      t.string :token

      # user
      t.text :to
      t.integer :user_id
      t.string :user_type

      # optional
      # feel free to remove
      t.string :mailer
      t.text :subject
      t.text :content

      # timestamps
      t.timestamp :sent_at
      t.timestamp :opened_at
      t.timestamp :clicked_at
    end

    add_index :ahoy_messages, [:token]
    add_index :ahoy_messages, [:user_id, :user_type]
  end
end
