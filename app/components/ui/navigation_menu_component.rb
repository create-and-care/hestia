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
  end
end
