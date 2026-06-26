module Ui
  class InputOtpComponent < ApplicationComponent
    def initialize(name:, length: 6)
      @name = name
      @length = length
    end
  end
end
