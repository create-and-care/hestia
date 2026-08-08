# The colour a *user* picked — a note's paper, a calendar event's chip, a
# document folder's dot, a service-provider type's dot.
#
# Four helpers each carried their own colour => classes table, so "what does a
# blue swatch look like" was answered four times, in four shapes. Centralising
# them turned up two things none of the four could see on its own:
#
#   * `purple` is offered by all four models and is not a colour this design
#     system defines. Every purple swatch in the app was rendering in stock
#     Tailwind purple. The system's purple ramp is `violet`, so the stored key
#     maps to it — see RAMPS.
#   * `-950` does not exist here either; the ramps stop at 900. So the dark
#     halves in Notes and Calendar (`dark:bg-yellow-950/40`) were off-palette
#     too, on top of being absent from Documents and Providers entirely.
#
# Deliberately not --module-* tokens: those name a household domain (Fridge,
# Tasks…), and a note the user chose to make blue has nothing to do with any of
# them. A user swatch is a hue, and the raw palette is the right register.
#
# The classes are spelled out rather than interpolated. Tailwind compiles the
# utilities it can *see* in the source, and `"bg-#{hue}-500"` is invisible to
# it — the class would resolve to nothing at runtime.
module Swatch
  # Neutral, unpainted. Notes offer it as a real choice ("no colour"); the dot
  # roles render nothing rather than a grey dot that reads as a choice.
  DEFAULT = "default"

  # The user-facing hue key, as stored in the database, mapped to the ramp that
  # renders it. Identity for every hue the design system names — except purple,
  # which it does not, and which violet is.
  RAMPS = {
    "gray" => "gray", "red" => "red", "orange" => "orange", "yellow" => "yellow",
    "green" => "green", "blue" => "blue", "pink" => "pink", "purple" => "violet"
  }.freeze

  HUES = RAMPS.keys.freeze

  # ── Roles ────────────────────────────────────────────────────────────────
  # One visual job each. A hue absent from a table is one no module offers for
  # that role; `fetch(hue, nil)` is what keeps that honest rather than guessing.

  # A tinted card — a note's paper. A -50 wash inside a -200 border, inverted
  # for dark mode.
  CARD = {
    "yellow" => "bg-yellow-50 border-yellow-200 dark:bg-yellow-900/40 dark:border-yellow-800",
    "pink" => "bg-pink-50 border-pink-200 dark:bg-pink-900/40 dark:border-pink-800",
    "blue" => "bg-blue-50 border-blue-200 dark:bg-blue-900/40 dark:border-blue-800",
    "green" => "bg-green-50 border-green-200 dark:bg-green-900/40 dark:border-green-800",
    "purple" => "bg-violet-50 border-violet-200 dark:bg-violet-900/40 dark:border-violet-800"
  }.freeze

  # A chip carrying text — a calendar event. Needs a foreground as well as a
  # ground, so it is its own role rather than a variant of CARD.
  CHIP = {
    "blue" => "bg-blue-100 text-blue-800 dark:bg-blue-900/50 dark:text-blue-200",
    "green" => "bg-green-100 text-green-800 dark:bg-green-900/50 dark:text-green-200",
    "red" => "bg-red-100 text-red-800 dark:bg-red-900/50 dark:text-red-200",
    "orange" => "bg-orange-100 text-orange-800 dark:bg-orange-900/50 dark:text-orange-200",
    "yellow" => "bg-yellow-100 text-yellow-800 dark:bg-yellow-900/50 dark:text-yellow-200",
    "pink" => "bg-pink-100 text-pink-800 dark:bg-pink-900/50 dark:text-pink-200",
    "purple" => "bg-violet-100 text-violet-800 dark:bg-violet-900/50 dark:text-violet-200",
    "gray" => "bg-gray-100 text-gray-800 dark:bg-gray-800/60 dark:text-gray-200"
  }.freeze

  # A filled circle — a folder dot, a provider-type dot. Gray takes -400 so it
  # stays distinguishable from the border it sits beside.
  DOT = {
    "gray" => "bg-gray-400", "red" => "bg-red-500", "orange" => "bg-orange-500",
    "yellow" => "bg-yellow-500", "green" => "bg-green-500", "blue" => "bg-blue-500",
    "pink" => "bg-pink-500", "purple" => "bg-violet-500"
  }.freeze

  # The swatch in a note's colour picker, where "default" is itself an option
  # and has to be shown as one.
  PAPER = {
    DEFAULT => "bg-surface-inset",
    "yellow" => "bg-yellow-300", "pink" => "bg-pink-300", "blue" => "bg-blue-300",
    "green" => "bg-green-300", "purple" => "bg-violet-300"
  }.freeze

  class << self
    def card_classes(hue) = CARD.fetch(normalize(hue), nil)
    def dot_classes(hue) = DOT.fetch(normalize(hue), nil)
    def paper_classes(hue) = PAPER.fetch(normalize(hue), PAPER.fetch(DEFAULT))

    # A calendar event with no colour set still has to render as something.
    def chip_classes(hue) = CHIP.fetch(normalize(hue), CHIP.fetch("blue"))

    private
      # A colour column is user-writable through the API, so an unknown value
      # must miss every table rather than reach a lookup that guesses.
      def normalize(hue) = hue.presence&.to_s
  end
end
