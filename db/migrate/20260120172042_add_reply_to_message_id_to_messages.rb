class AddReplyToMessageIdToMessages < ActiveRecord::Migration[8.0]
  def change
    add_column :messages, :reply_to_message_id, :string
  end
end
