module Reordering
  # Applies an order (list of ids) to a set of records that have a
  # `position` column. Shared by Shopping, Tasks and Loyalty.
  def self.apply(scope, ids)
    ids = Array(ids).map(&:to_s)
    scope.where(id: ids).find_each do |record|
      position = ids.index(record.id.to_s)
      record.update_column(:position, position) if position
    end
  end
end
