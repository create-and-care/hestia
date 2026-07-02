class CreateCircleMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :circle_memberships do |t|
      t.references :circle, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :role, null: false, default: "member"

      t.timestamps
    end

    add_index :circle_memberships, [ :circle_id, :user_id ], unique: true
  end
end
