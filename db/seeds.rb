# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Catalogue d'enseignes de fidélité (CDC §10.5, §16) — constitué progressivement ;
# une carte "hors catalogue" reste toujours possible pour les enseignes manquantes.
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
