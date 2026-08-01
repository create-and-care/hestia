module Ui
  # Overlapping stack of Avatars for a group of people at a glance, each one
  # revealing its identity on hover/focus via a Tooltip — inspired by
  # shadcn's Avatar Group (https://ui.shadcn.com/docs/components/base/avatar).
  class AvatarGroupComponent < ApplicationComponent
    # Overlap scales with avatar size so the stack reads correctly at any SIZES value.
    OVERLAP = { sm: "-space-x-2", default: "-space-x-2.5", lg: "-space-x-3.5" }.freeze

    # members: [{ alt: "Jane Doe", label: "Jane Doe — Admin" }, { alt: "John Doe", src: "..." }]
    # label defaults to alt when omitted.
    def initialize(members:, max: 5, size: :default)
      @members = members
      @max = max
      @size = size
    end

    def visible_members
      @members.first(@max)
    end

    def overflow_count
      [ @members.size - @max, 0 ].max
    end
  end
end
