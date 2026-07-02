module Frigo
  # Ajoute un produit au frigo (emplacement + date de péremption), en alimentant le
  # catalogue du foyer. Service applicatif invocable par le web, l'API et Hest.IA.
  class AddItem
    def self.call(...) = new(...).call

    def initialize(household:, name:, location: "refrigerateur", expires_on: nil, product: nil)
      @household = household
      @name = name.to_s.strip
      @location = location.presence || "refrigerateur"
      @expires_on = expires_on
      @product = product
    end

    def call
      @product ||= Product.catalog_for(household: @household, name: @name) if @name.present?

      @household.fridge_items.create!(
        name: @name,
        location: @location,
        expires_on: @expires_on,
        product: @product
      )
    end
  end
end
