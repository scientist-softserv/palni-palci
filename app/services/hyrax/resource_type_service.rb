# frozen_string_literal: true

module Hyrax
  # Provide select options for the types field
  class ResourceTypeService < QaSelectService
    mattr_accessor :authority
    self.authority = Qa::Authorities::Local.subauthority_for('resource_types')

    def initialize(_authority_name = nil)
      super('resource_types')
    end

    def self.select_options
      authority.all.map do |element|
        [element[:label], element[:id]]
      end
    end

    def self.label(id)
      authority.find(id).fetch('term')
    end
  end
end
