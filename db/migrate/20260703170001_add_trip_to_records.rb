class AddTripToRecords < ActiveRecord::Migration[8.1]
  def change
    # Generic cross-cutting context: these records can be attached to a trip
    # in addition to the household (Spec §5, point 3 / §12.3).
    add_reference :notes, :trip, null: true, foreign_key: true
    add_reference :tasks, :trip, null: true, foreign_key: true
    add_reference :shopping_lists, :trip, null: true, foreign_key: true
    add_reference :addresses, :trip, null: true, foreign_key: true
  end
end
