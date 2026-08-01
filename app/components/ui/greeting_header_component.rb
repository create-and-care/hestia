module Ui
  # Dashboard opening line — a time-of-day greeting in the handwritten accent
  # font (see .greeting in application.tailwind.css), plus an optional
  # situational lead line underneath. One line at a time, never a data view.
  class GreetingHeaderComponent < ApplicationComponent
    GREETING_KEYS = {
      (0..4) => :night,
      (5..10) => :morning,
      (11..13) => :lunch,
      (14..17) => :afternoon,
      (18..21) => :evening,
      (22..23) => :late_evening
    }.freeze

    def initialize(name:, lead: nil, hour: nil, greeting: nil, class_name: nil)
      @name = name
      @lead = lead
      @hour = hour || Time.current.hour
      @greeting = greeting || default_greeting
      @class_name = class_name
    end

    private

    def default_greeting
      key = GREETING_KEYS.find { |range, _| range.cover?(@hour) }&.last || :morning
      I18n.t("ui.greeting_header.#{key}")
    end
  end
end
