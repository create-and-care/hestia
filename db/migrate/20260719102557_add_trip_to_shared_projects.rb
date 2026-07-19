class AddTripToSharedProjects < ActiveRecord::Migration[8.1]
  def change
    add_reference :shared_projects, :trip, null: true, foreign_key: true
  end
end
