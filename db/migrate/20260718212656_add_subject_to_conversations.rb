class AddSubjectToConversations < ActiveRecord::Migration[8.1]
  def change
    add_reference :conversations, :subject, polymorphic: true, null: true
  end
end
