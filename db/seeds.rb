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

# Catalogue de fiches d'entretien de plantes (CDC §11.3, §16) — constitué
# progressivement ; une Plante sans fiche associée reste pleinement fonctionnelle.
[
  { common_name: "Basilic", scientific_name: "Ocimum basilicum", water_needs: "Fréquent (sol toujours humide)",
    sunlight: "Plein soleil", pruning: "Pincer les fleurs pour prolonger la récolte",
    common_diseases: "Fonte des semis, pucerons" },
  { common_name: "Tomate", scientific_name: "Solanum lycopersicum", water_needs: "Régulier, éviter le feuillage",
    sunlight: "Plein soleil", pruning: "Supprimer les gourmands",
    common_diseases: "Mildiou, oïdium" },
  { common_name: "Lavande", scientific_name: "Lavandula", water_needs: "Faible, sol drainant",
    sunlight: "Plein soleil", pruning: "Tailler après floraison",
    common_diseases: "Pourriture racinaire si excès d'eau" },
  { common_name: "Monstera", scientific_name: "Monstera deliciosa", water_needs: "Modéré, laisser sécher entre deux arrosages",
    sunlight: "Lumière indirecte", pruning: "Retirer les feuilles jaunies",
    common_diseases: "Cochenilles, araignées rouges" },
  { common_name: "Rosier", scientific_name: "Rosa", water_needs: "Régulier au pied",
    sunlight: "Plein soleil à mi-ombre", pruning: "Taille en fin d'hiver",
    common_diseases: "Oïdium, taches noires, pucerons" },
  { common_name: "Orchidée", scientific_name: "Phalaenopsis", water_needs: "Faible, par trempage hebdomadaire",
    sunlight: "Lumière indirecte vive", pruning: "Couper la hampe florale fanée",
    common_diseases: "Pourriture des racines si excès d'eau" }
].each do |attributes|
  PlantReference.find_or_create_by!(common_name: attributes[:common_name]) { |reference| reference.assign_attributes(attributes) }
end
