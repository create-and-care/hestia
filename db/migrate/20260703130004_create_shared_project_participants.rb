class CreateSharedProjectParticipants < ActiveRecord::Migration[8.1]
  def change
    create_table :shared_project_participants do |t|
      t.references :shared_project, null: false, foreign_key: true
      t.string :name, null: false

      t.timestamps
    end
  end
end
