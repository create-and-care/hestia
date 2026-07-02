module ContactsHelper
  PROXIMITY = {
    today: [ "Aujourd'hui !", "bg-red-100 text-red-700" ],
    week:  [ "Cette semaine", "bg-orange-100 text-orange-700" ],
    month: [ "Ce mois-ci", "bg-yellow-100 text-yellow-800" ],
    later: [ "Plus tard", "bg-gray-100 text-gray-600" ],
    none:  [ "Sans date", "bg-gray-100 text-gray-400" ]
  }.freeze

  def proximity_label(status) = PROXIMITY.fetch(status).first
  def proximity_badge_class(status) = PROXIMITY.fetch(status).last
end
