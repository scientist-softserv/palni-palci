# frozen_string_literal: true

module Hyrax
  # Provide select options for the types field
  class ResourceTypeService < QaSelectService
    def initialize(_authority_name = nil)
      super('resource_types')
    end
  end
end
