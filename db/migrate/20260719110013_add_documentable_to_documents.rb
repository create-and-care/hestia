class AddDocumentableToDocuments < ActiveRecord::Migration[8.1]
  def change
    add_reference :documents, :documentable, polymorphic: true, null: true
  end
end
