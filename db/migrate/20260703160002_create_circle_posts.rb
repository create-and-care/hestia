class CreateCirclePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :circle_posts do |t|
      t.references :circle, null: false, foreign_key: true
      t.references :author, null: false, foreign_key: { to_table: :users }
      t.text :body, null: false

      t.timestamps
    end
  end
end
