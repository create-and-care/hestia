module Ui
  # A file-attachment chip for a message composer — name, optional size, and
  # a remove button.
  class AttachmentComponent < ApplicationComponent
    def initialize(name:, size: nil, removable: true)
      @name = name
      @size = size
      @removable = removable
    end
  end
end
