module Courses
  # Bascule l'état « pris en magasin » d'un article. Service applicatif réutilisable
  # par le web, l'API et Hest.IA.
  class ToggleItem
    def self.call(item:)
      item.update!(checked: !item.checked)
      item
    end
  end
end
