# frozen_string_literal: true

module Hyrax
  module TypesService
    mattr_accessor :authority
    self.authority = Qa::Authorities::Local.subauthority_for('types')

    def self.select_options
      authority.all.map do |element|
        [element[:label], element[:id]]
      end
    end

    def self.label(id)
      authority.find(id).fetch('term')
    end

    def self.microdata_type(id)
      return Hyrax.config.microdata_default_type if id.nil?
      Microdata.fetch("types.#{id}", default: Hyrax.config.microdata_default_type)
    end
  end
end