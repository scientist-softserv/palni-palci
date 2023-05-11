# frozen_string_literal: true
module Hyrax
  # Provide select options for the types field
  class FormatService < QaSelectService
    def initialize(_authority_name = nil)
      super('formats')
    end
  end
end
