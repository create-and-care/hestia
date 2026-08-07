namespace :i18n do
  desc "Fail on any missing translation, and on any key present in one locale but not the other (I18N-02)"
  task check: :environment do
    require "i18n/tasks"

    task_runner = I18n::Tasks::BaseTask.new
    missing = task_runner.missing_keys

    unless missing.empty?
      task_runner.forest_stats(missing)
      abort "#{missing.leaves.count} missing translation(s):\n#{missing.inspect}\n\n" \
        "Add them, or teach config/i18n-tasks.yml why they are not real."
    end

    # `missing` only looks outward from the base locale: a key that exists in
    # fr and not in en is not missing, it is invisible. Hence the second pass.
    en, fr = %i[en fr].map { |locale| locale_keys(locale) }
    strays = { "no French translation" => en - fr, "no English translation" => fr - en }
      .reject { |_, keys| keys.empty? }

    unless strays.empty?
      abort strays.map { |label, keys| "Keys with #{label}:\n  #{keys.join("\n  ")}" }.join("\n\n")
    end

    puts "i18n: en and fr agree — no missing keys, no strays in either direction."
  end

  def locale_keys(locale)
    Dir[Rails.root.join("config/locales/#{locale}/*.yml")].flat_map do |path|
      flatten_keys(YAML.unsafe_load_file(path)[locale.to_s] || {})
    end
  end

  def flatten_keys(node, prefix = "")
    node.flat_map do |key, value|
      value.is_a?(Hash) ? flatten_keys(value, "#{prefix}#{key}.") : "#{prefix}#{key}"
    end
  end
end
