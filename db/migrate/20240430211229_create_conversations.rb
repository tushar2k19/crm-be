class CreateConversations < ActiveRecord::Migration[7.1]
  def change
    create_table :conversations do |t|
      t.text :last_message
      t.string :last_conv_time
      t.references :profile, null: false, foreign_key: true

      t.timestamps
    end
  end
end
