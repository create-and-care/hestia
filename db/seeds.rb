# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Loyalty brand catalog — built up progressively; an
# "out of catalog" card is always available for brands not yet listed.
[
  { name: "Carrefour", logo_emoji: "🛒", code_format: "barcode" },
  { name: "Leclerc", logo_emoji: "🛒", code_format: "barcode" },
  { name: "Auchan", logo_emoji: "🛒", code_format: "barcode" },
  { name: "Intermarché", logo_emoji: "🛒", code_format: "barcode" },
  { name: "Monoprix", logo_emoji: "🛍️", code_format: "barcode" },
  { name: "Fnac", logo_emoji: "📚", code_format: "qrcode" },
  { name: "Décathlon", logo_emoji: "⚽", code_format: "barcode" },
  { name: "Sephora", logo_emoji: "💄", code_format: "qrcode" },
  { name: "IKEA", logo_emoji: "🛋️", code_format: "qrcode" },
  { name: "Boulanger", logo_emoji: "🔌", code_format: "barcode" }
].each do |attributes|
  LoyaltyBrand.find_or_create_by!(name: attributes[:name]) { |brand| brand.assign_attributes(attributes) }
end

# Plant care-sheet catalog — built up progressively; a
# Plant with no reference attached stays fully functional.
[
  { common_name: "Basil", scientific_name: "Ocimum basilicum", water_needs: "Frequent (soil always moist)",
    sunlight: "Full sun", pruning: "Pinch off flowers to prolong the harvest",
    common_diseases: "Damping-off, aphids", fertilizing: "Balanced liquid fertilizer every 2 weeks in growing season" },
  { common_name: "Tomato", scientific_name: "Solanum lycopersicum", water_needs: "Regular, avoid wetting the foliage",
    sunlight: "Full sun", pruning: "Remove suckers",
    common_diseases: "Blight, powdery mildew", fertilizing: "Potassium-rich fertilizer every 2 weeks once fruiting starts" },
  { common_name: "Lavender", scientific_name: "Lavandula", water_needs: "Low, well-drained soil",
    sunlight: "Full sun", pruning: "Prune after flowering",
    common_diseases: "Root rot if overwatered", fertilizing: "None needed; overfeeding reduces fragrance" },
  { common_name: "Monstera", scientific_name: "Monstera deliciosa", water_needs: "Moderate, let dry between waterings",
    sunlight: "Indirect light", pruning: "Remove yellowed leaves",
    common_diseases: "Mealybugs, spider mites", fertilizing: "Diluted houseplant fertilizer monthly in spring/summer" },
  { common_name: "Rose bush", scientific_name: "Rosa", water_needs: "Regular, at the base",
    sunlight: "Full sun to partial shade", pruning: "Prune in late winter",
    common_diseases: "Powdery mildew, black spot, aphids", fertilizing: "Rose fertilizer in spring and after first bloom" },
  { common_name: "Orchid", scientific_name: "Phalaenopsis", water_needs: "Low, weekly soaking",
    sunlight: "Bright indirect light", pruning: "Cut the faded flower spike",
    common_diseases: "Root rot if overwatered", fertilizing: "Weak orchid fertilizer every 2-4 weeks while blooming" }
].each do |attributes|
  PlantReference.find_or_create_by!(common_name: attributes[:common_name]) { |reference| reference.assign_attributes(attributes) }
end
