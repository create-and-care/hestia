module Courses
  # Adds an item to a shopping list, feeding the household's product catalog
  # along the way and inferring the aisle. Exposed as an application service
  # (rather than controller logic) so it can be invoked by Hest.AI in
  # Phase 3 (Spec §5, point 5).
  class AddItem
    def self.call(...) = new(...).call

    def initialize(shopping_list:, name:, quantity: nil, unit: nil, rayon: nil, product: nil, recipe: nil)
      @shopping_list = shopping_list
      @name = name.to_s.strip
      @quantity = quantity
      @unit = unit.presence
      @rayon = rayon.presence
      @product = product
      @recipe = recipe
    end

    def call
      @product ||= catalog_product
      rayon = @rayon || @product&.rayon || Courses::GuessRayon.call(@name)

      @shopping_list.items.create!(
        name: @name,
        quantity: @quantity,
        unit: @unit,
        rayon: rayon,
        product: @product,
        recipe: @recipe,
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
