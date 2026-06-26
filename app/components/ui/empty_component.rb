module Ui
  class EmptyComponent < ApplicationComponent
    renders_one :icon
    renders_one :title
    renders_one :description
    renders_one :action
  end
end
