module BabyProfilesHelper
  def feeding_kind_label(kind) = t("baby_profiles.feeding_kinds.#{kind}", default: kind)
  def feeding_kind_options = FeedingSession::KINDS.map { |kind| [ feeding_kind_label(kind), kind ] }
end
