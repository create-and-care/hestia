module Courses
  # Best-effort aisle guess for a shopping list item that has no product
  # history yet (Courses::AddItem's fallback before "autre") — simple keyword
  # matching, no external service, so an ingredient's first appearance still
  # lands in a sensible aisle instead of always "autre".
  class GuessRayon
    KEYWORDS = {
      "hygiene" => %w[savon dentifrice shampoing shampooing déodorant rasoir coton papier\ toilette],
      "maison" => %w[éponge liquide\ vaisselle sac\ poubelle lessive essuie-tout ampoule pile],
      "surgeles" => %w[surgelé surgelée surgelés glace glacé sorbet],
      "boissons" => %w[eau jus vin bière soda café thé mojito limonade],
      "frais" => %w[
        lait fromage yaourt beurre crème œuf oeuf
        poulet bœuf boeuf porc veau agneau viande jambon lardons saucisse chorizo coppa nduja
        poisson saumon thon cabillaud truite crevette haddock crevettes
        tofu paneer labneh pecorino grana\ padano chèvre fourme mozzarella burrata
      ],
      "fruits_legumes" => %w[
        tomate oignon ail carotte pomme\ de\ terre patate courgette aubergine poivron
        salade laitue concombre citron orange banane pomme poire fraise avocat
        champignon brocoli épinard fenouil chou persil basilic coriandre menthe
        gingembre mangue échalote poireau
      ],
      "epicerie" => %w[
        farine sucre sel poivre huile vinaigre riz pâtes pate quinoa boulgour
        lentille pois\ chiche conserve chapelure panko épice épices cumin paprika
        curry sauce mayonnaise ketchup moutarde miel confiture chocolat biscuit
        pain naan tortilla focaccia levure bouillon sriracha mélasse tahini
      ]
    }.freeze

    def self.call(name) = new(name).call

    def initialize(name)
      @name = name.to_s.downcase
    end

    def call
      KEYWORDS.each do |rayon, keywords|
        return rayon if keywords.any? { |keyword| @name.include?(keyword) }
      end
      "autre"
    end
  end
end
