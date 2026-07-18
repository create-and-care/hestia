class AddLastReadAtToConversationParticipants < ActiveRecord::Migration[8.1]
  def change
    add_column :conversation_participants, :last_read_at, :datetime
  end
end
