module Ui
  class AccordionComponent < ApplicationComponent
    class Item < ApplicationComponent
      attr_reader :title, :key

      def initialize(title:, key:)
        @title = title
        @key = key
      end

      def call
        content
      end
    end

    renders_many :items, Item

    def initialize(multiple: false)
      @multiple = multiple
    end
  end
end
