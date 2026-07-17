module Reordering
  # Applies an order (list of ids) to a set of records that have a
  # `position` column. Shared by Shopping, Tasks and Loyalty.
  #
  # Uses update! rather than update_column: several of these models
  # broadcast themselves to the household via an after_update_commit /
  # broadcasts_to callback, and update_column skips callbacks entirely —
  # which silently meant drag-and-drop reordering never synced in
  # real time to other household members.
  def self.apply(scope, ids)
    ids = Array(ids).map(&:to_s)
    scope.where(id: ids).find_each do |record|
      position = ids.index(record.id.to_s)
      record.update!(position: position) if position
    end
  end
end
