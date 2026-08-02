module Ui
  class CopyButtonComponent < ApplicationComponent
    def initialize(value:, label:, message: nil, html_options: {})
      @value = value
      @label = label
      @message = message
      @html_options = html_options
    end
  end
end
