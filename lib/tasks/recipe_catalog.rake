namespace :recipes do
  namespace :catalog do
    desc "Crawl a draft batch of recipe pages into tmp/recipe_catalog_draft.yml for manual rewriting"
    task :draft, [ :limit ] => :environment do |_, args|
      limit = (args[:limit].presence || 150).to_i
      candidates = Recipes::Catalog::DiscoverUrls.call(limit: limit)
      abort "No URLs discovered — check RECIPE_CATALOG_SITEMAP_URL." if candidates.empty?

      drafts = candidates.each_with_index.filter_map do |candidate, index|
        sleep 0.3 if index.positive? # a small courtesy delay between requests to the source site
        html = Recipes::PageFetcher.call(candidate.url)
        next if html.blank?

        parsed = Recipes::RecipeParser.parse(html)
        next if parsed.nil? || parsed.title.blank?

        {
          "source_url" => candidate.url,
          "title" => parsed.title,
          "servings" => parsed.servings,
          "prep_time_minutes" => parsed.prep_time_minutes,
          "cook_time_minutes" => parsed.cook_time_minutes,
          "ingredients" => parsed.ingredients,
          "steps" => parsed.steps
        }
      end

      draft_path = Rails.root.join("tmp/recipe_catalog_draft.yml")
      File.write(draft_path, drafts.to_yaml)
      puts "Wrote #{drafts.size}/#{candidates.size} draft recipes to #{draft_path}"
    end

    desc "Load db/seeds/recipe_catalog.yml (already-rewritten content) into RecipeCatalogEntry"
    task load: :environment do
      seed_path = Rails.root.join("db/seeds/recipe_catalog.yml")
      abort "Missing #{seed_path}" unless File.exist?(seed_path)

      entries = YAML.load_file(seed_path)
      entries.each do |data|
        entry = RecipeCatalogEntry.find_or_initialize_by(source_url: data["source_url"])
        entry.assign_attributes(
          title: data["title"],
          tags: data["tags"] || [],
          servings: data["servings"],
          prep_time_minutes: data["prep_time_minutes"],
          cook_time_minutes: data["cook_time_minutes"],
          ingredients: data["ingredients"] || [],
          steps: data["steps"] || [],
          last_synced_at: Time.current
        )
        entry.save!
      end
      puts "Loaded #{entries.size} recipe catalog entries"
    end
  end
end
