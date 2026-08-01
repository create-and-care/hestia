module Ui
  # Overlapping stack of Avatars for a group of people at a glance, each one
  # revealing its identity on hover/focus via a Tooltip — inspired by
  # shadcn's Avatar Group (https://ui.shadcn.com/docs/components/base/avatar).
  class AvatarGroupComponent < ApplicationComponent
    # Overlap scales with avatar size so the stack reads correctly at any SIZES value.
    OVERLAP = { sm: "-space-x-2", default: "-space-x-2.5", lg: "-space-x-3.5" }.freeze

    # members: [{ alt:, src:, fallback:, label:, tint: }, ...] — an
    # AvatarGroupMember shape (plain Hash; Ruby has no static struct for view
    # data here, so this comment is the type). alt and label are the only
    # required keys in practice; label defaults to alt when omitted; tint is
    # forwarded to Ui::AvatarComponent as-is (module key or raw CSS color) and
    # left nil to fall into that component's own hashed default.
    # e.g. [{ alt: "Jane Doe", label: "Jane Doe — Admin", tint: :budget }, { alt: "John Doe", src: "..." }]
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
