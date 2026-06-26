module Ui
  class TabsComponent < ApplicationComponent
    class Tab < ApplicationComponent
      attr_reader :label, :value

      def initialize(label:, value:)
        @label = label
        @value = value
      end

      def call
        content
      end
    end

    renders_many :tabs, Tab

    def initialize(default: nil)
      @default = default
    end

    def active_value
      @default || tabs.first&.value
    end
  end
end
