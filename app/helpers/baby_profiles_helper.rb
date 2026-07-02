module BabyProfilesHelper
  KIND_LABELS = { "bottle" => "Biberon", "breast" => "Allaitement" }.freeze

  def feeding_kind_label(kind) = KIND_LABELS.fetch(kind, kind)
  def feeding_kind_options = FeedingSession::KINDS.map { |kind| [ feeding_kind_label(kind), kind ] }
end
