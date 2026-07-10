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
      @uid = SecureRandom.hex(4)
    end

    def panel_id(key)
      "accordion-#{@uid}-panel-#{key}"
    end
  end
end
