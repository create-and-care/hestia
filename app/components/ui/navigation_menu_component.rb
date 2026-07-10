module Ui
  class NavigationMenuComponent < ApplicationComponent
    class Menu < ApplicationComponent
      attr_reader :label, :key

      def initialize(label:, key:)
        @label = label
        @key = key
      end

      def call
        content
      end
    end

    renders_many :menus, Menu

    def initialize
      @uid = SecureRandom.hex(4)
    end

    def trigger_id(key)
      "navigation-menu-#{@uid}-trigger-#{key}"
    end

    def panel_id(key)
      "navigation-menu-#{@uid}-panel-#{key}"
    end
  end
end
