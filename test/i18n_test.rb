require "test_helper"
require "i18n/tasks"

# en and fr have been kept at the same key count by hand. Hand-kept parity
# drifts — quietly, and always toward whichever language the person writing the
# feature thinks in. This is the check that replaces the discipline (I18N-02).
#
# Only `missing` is asserted; see the reasoning in config/i18n-tasks.yml for
# why `unused` is not, yet.
class I18nTest < ActiveSupport::TestCase
  def setup
    @i18n = I18n::Tasks::BaseTask.new
    @missing = @i18n.missing_keys
  end

  test "no translation is missing from either locale" do
    assert_empty @missing, "#{@missing.leaves.count} missing keys:\n#{@missing.inspect}"
  end

  # `missing` only looks one way from the base locale: a key that exists in fr
  # and not in en is not "missing", it is invisible. Both directions are
  # asserted here, which is the 1 985 = 1 985 parity the repo has been holding
  # by hand.
  #
  # Not asserted: normalization. `i18n-tasks normalize` round-trips the files
  # through a YAML dump, which would delete every comment in config/locales —
  # and those comments are the only place a key's intent is written down.
  test "en and fr describe exactly the same key set" do
    only_in_en = leaves(:en) - leaves(:fr)
    only_in_fr = leaves(:fr) - leaves(:en)

    assert_empty only_in_en, "keys with no French translation:\n  #{only_in_en.join("\n  ")}"
    assert_empty only_in_fr, "keys with no English translation:\n  #{only_in_fr.join("\n  ")}"
  end

  private
    def leaves(locale)
      Dir[Rails.root.join("config/locales/#{locale}/*.yml")].flat_map do |path|
        flatten(YAML.unsafe_load_file(path)[locale.to_s] || {})
      end
    end

    def flatten(node, prefix = "")
      node.flat_map do |key, value|
        value.is_a?(Hash) ? flatten(value, "#{prefix}#{key}.") : "#{prefix}#{key}"
      end
    end
end
