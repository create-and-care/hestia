class CreateCirclePostReactions < ActiveRecord::Migration[8.1]
  def change
    create_table :circle_post_reactions do |t|
      t.references :circle_post, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :emoji, null: false

      t.timestamps
    end

    add_index :circle_post_reactions, [ :circle_post_id, :user_id ], unique: true
  end
end
