module QuickCapture
  # Rule-based destination guess for a captured phrase (see roadmap: "à base de
  # règles plutôt que d'un appel à un modèle") — never the only outcome, since
  # the caller always keeps the phrase as a note regardless of what this
  # returns; a match just offers one tap towards a better home for it.
  class AnalyzeText
    DATE_WORDS = %w[
      demain après-demain aujourd'hui lundi mardi mercredi jeudi vendredi samedi dimanche
      tomorrow today monday tuesday wednesday thursday friday saturday sunday
    ].freeze
    NUMERIC_DATE_REGEX = /\b\d{1,2}[\/\-.]\d{1,2}(?:[\/\-.]\d{2,4})?\b/

    def self.call(...) = new(...).call

    def initialize(household:, text:)
      @household = household
      @text = text.to_s
    end

    def call
      return :task if date_mentioned?
      return :shopping if Product.matching(household: @household, text: @text)

      :note
    end

    private
      def date_mentioned?
        normalized = @text.downcase
        @text.match?(NUMERIC_DATE_REGEX) || DATE_WORDS.any? { |word| normalized.include?(word) }
      end
  end
end
