module Reordering
  # Applique un ordre (liste d'identifiants) à un ensemble d'enregistrements portant
  # une colonne `position`. Mutualisé par Courses, Tâches et Fidélité.
  def self.apply(scope, ids)
    ids = Array(ids).map(&:to_s)
    scope.where(id: ids).find_each do |record|
      position = ids.index(record.id.to_s)
      record.update_column(:position, position) if position
    end
  end
end
