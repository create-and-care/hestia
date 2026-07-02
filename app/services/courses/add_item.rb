module Courses
  # Ajoute un article à une liste de courses, en alimentant au passage le
  # catalogue de produits du foyer et en déduisant le rayon. Exposé comme service
  # applicatif (et non logique de contrôleur) pour être invocable par Hest.IA en
  # Phase 3 (CDC §5, point 5).
  class AddItem
    def self.call(...) = new(...).call

    def initialize(shopping_list:, name:, quantity: nil, unit: nil, rayon: nil, product: nil)
      @shopping_list = shopping_list
      @name = name.to_s.strip
      @quantity = quantity
      @unit = unit.presence
      @rayon = rayon.presence
      @product = product
    end

    def call
      @product ||= catalog_product
      rayon = @rayon || @product&.rayon || "autre"

      @shopping_list.items.create!(
        name: @name,
        quantity: @quantity,
        unit: @unit,
        rayon: rayon,
        product: @product,
        position: next_position
      )
    end

    private
      def catalog_product
        return if @name.blank?

        Product.catalog_for(household: @shopping_list.household, name: @name, rayon: @rayon)
      end

      def next_position
        (@shopping_list.items.maximum(:position) || -1) + 1
      end
  end
end
