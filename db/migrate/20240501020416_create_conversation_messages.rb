class CreateConversationMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :conversation_messages do |t|
      t.text :message
      t.string :sent_at
      t.string :sent_by
      t.references :conversation, null: false, foreign_key: true

      t.timestamps
    end
  end
end
