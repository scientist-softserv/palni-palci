# frozen_string_literal: true
module Hyrax
  # Provide select options for the types field
  class TypesService < QaSelectService
    def initialize(_authority_name = nil)
      super('types')
    end
  end
end