# frozen_string_literal: true

module Hyrax
  # Provide select options for the types field
  class InstitutionService < QaSelectService
    def initialize(_authority_name = nil)
      super('institutions')
    end
  end
end
