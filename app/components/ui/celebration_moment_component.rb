module Ui
  # Warm dashboard callout for a birthday coming up, a maintained streak, or
  # a milestone — tinted band, dismissible, at most one on screen at a time.
  # No emoji, no exclamation points.
  class CelebrationMomentComponent < ApplicationComponent
    KINDS = {
      birthday: { mod: :gifts, icon: "cake" },
      streak: { mod: :courses, icon: "sprout" },
      milestone: { mod: :calendar, icon: "star" }
    }.freeze

    renders_one :action

    def initialize(kind: :birthday, title:, note: nil, class_name: nil)
      @kind = kind
      @title = title
      @note = note
      @class_name = class_name
    end

    def medallion
      KINDS.fetch(@kind)
    end
  end
end
