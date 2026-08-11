module Frigo
  # Adds a product to the fridge (location + expiration date), feeding the
  # household's catalog. Application service invocable by the web, the API and Hest.AI.
  class AddItem
    def self.call(...) = new(...).call

    def initialize(household:, name:, location: "refrigerateur", expires_on: nil, quantity: nil, unit: nil, product: nil)
      @household = household
      @name = name.to_s.strip
      @location = location.presence || "refrigerateur"
      @expires_on = expires_on
      @quantity = quantity
      @unit = unit.presence
      @product = product
    end

    def call
      @product ||= Product.catalog_for(household: @household, name: @name) if @name.present?

      @household.fridge_items.create!(
        name: @name,
        location: @location,
        expires_on: @expires_on,
        quantity: @quantity,
        unit: @unit,
        product: @product
      )
    end
  end
end
