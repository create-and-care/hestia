namespace :i18n do
  desc "Fail on a missing or unused translation, or on a key present in one locale but not the other (I18N-02)"
  # Deliberately not `=> :environment`. Nothing here needs the app booted:
  # i18n-tasks reads the YAML files and greps the source. Depending on the
  # environment would mean the CI lint job needs a database, credentials and
  # the compiled assets to answer a question about two directories of YAML.
  task :check do
    require "i18n/tasks"
    require "yaml"

    task_runner = I18n::Tasks::BaseTask.new
    missing = task_runner.missing_keys

    unless missing.empty?
      abort "#{missing.leaves.count} missing translation(s):\n#{missing.inspect}\n\n" \
        "Add them, or teach config/i18n-tasks.yml why they are not real."
    end

    # A key nobody reads is a translation someone will keep translating.
    unused = task_runner.unused_keys
    unless unused.empty?
      abort "#{unused.leaves.count} unused translation(s):\n#{unused.inspect}\n\n" \
        "Delete them, or add the pattern to ignore_unused in config/i18n-tasks.yml " \
        "if the call site is real but not a literal t()."
    end

    # `missing` only looks outward from the base locale: a key that exists in
    # fr and not in en is not missing, it is invisible. Hence the second pass.
    en, fr = %i[en fr].map { |locale| locale_keys(locale) }
    strays = { "no French translation" => en - fr, "no English translation" => fr - en }
      .reject { |_, keys| keys.empty? }

    unless strays.empty?
      abort strays.map { |label, keys| "Keys with #{label}:\n  #{keys.join("\n  ")}" }.join("\n\n")
    end

    puts "i18n: en and fr agree — nothing missing, nothing unused, no strays in either direction."
  end

  def locale_keys(locale)
    Dir[File.expand_path("../../config/locales/#{locale}/*.yml", __dir__)].flat_map do |path|
      flatten_keys(YAML.unsafe_load_file(path)[locale.to_s] || {})
    end
  end

  def flatten_keys(node, prefix = "")
    node.flat_map do |key, value|
      value.is_a?(Hash) ? flatten_keys(value, "#{prefix}#{key}.") : "#{prefix}#{key}"
    end
  end
end
