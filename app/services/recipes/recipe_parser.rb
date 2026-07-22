require "json"
require "nokogiri"

module Recipes
  # Extracts a recipe from a page's JSON-LD schema.org/Recipe microdata
  # (basic import). Pure (no network access): testable on raw HTML.
  class RecipeParser
    Result = Struct.new(:title, :ingredients, :steps, :servings,
      :prep_time_minutes, :cook_time_minutes, :image_url, keyword_init: true)

    def self.parse(html) = new(html).parse

    def initialize(html)
      @html = html.to_s
    end

    def parse
      node = recipe_node
      return if node.nil?

      Result.new(
        title: string(node["name"]),
        ingredients: string_array(node["recipeIngredient"] || node["ingredients"]),
        steps: instructions(node["recipeInstructions"]),
        servings: servings(node["recipeYield"]),
        prep_time_minutes: iso8601_minutes(node["prepTime"]),
        cook_time_minutes: iso8601_minutes(node["cookTime"]),
        image_url: image_url(node["image"])
      )
    end

    private
      def recipe_node
        json_ld_blocks.each do |raw|
          parsed = begin
            JSON.parse(raw)
          rescue JSON::ParserError
            nil
          end
          next if parsed.nil?

          node = find_recipe(parsed)
          return node if node
        end
        nil
      end

      def json_ld_blocks
        Nokogiri::HTML(@html).css('script[type="application/ld+json"]').map(&:text)
      end

      def find_recipe(node)
        case node
        when Array
          node.lazy.filter_map { |child| find_recipe(child) }.first
        when Hash
          return node if recipe_type?(node["@type"])
          find_recipe(node["@graph"]) if node["@graph"].is_a?(Array)
        end
      end

      def recipe_type?(type)
        Array(type).map(&:to_s).include?("Recipe")
      end

      def string(value)
        (value.is_a?(Array) ? value.first : value).to_s.strip
      end

      def string_array(value)
        Array(value).map { |item| item.to_s.strip }.reject(&:blank?)
      end

      def instructions(value)
        case value
        when String then value.split(/\r?\n/).map(&:strip).reject(&:blank?)
        when Array then value.flat_map { |step| instruction_text(step) }.reject(&:blank?)
        else []
        end
      end

      def instruction_text(step)
        case step
        when String then [ step.strip ]
        when Hash
          if step["itemListElement"].is_a?(Array)
            step["itemListElement"].flat_map { |child| instruction_text(child) }
          else
            [ step["text"].to_s.strip ]
          end
        else []
        end
      end

      def servings(value)
        string(value)[/\d+/]&.to_i
      end

      # schema.org/Recipe's `image` is a URL string, an array of URLs, or an
      # ImageObject (or array thereof) with its own `url` property.
      def image_url(value)
        candidate = value.is_a?(Array) ? value.first : value
        case candidate
        when String then candidate.strip.presence
        when Hash then candidate["url"].to_s.strip.presence
        end
      end

      def iso8601_minutes(value)
        return if value.blank?

        match = value.to_s.match(/P(?:(\d+)D)?T(?:(\d+)H)?(?:(\d+)M)?/)
        return unless match

        days, hours, minutes = match.captures.map(&:to_i)
        total = (days * 1440) + (hours * 60) + minutes
        total.positive? ? total : nil
      end
  end
end
