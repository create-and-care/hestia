module Courses
  # Toggles an item's "picked up in store" state. Application service reusable
  # by the web, the API and Hest.AI.
  class ToggleItem
    def self.call(item:)
      item.update!(checked: !item.checked)
      item
    end
  end
end
