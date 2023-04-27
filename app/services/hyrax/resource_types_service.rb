module Hyrax
  module ResourceTypesService
    mattr_accessor :authority
    self.authority = Qa::Authorities::Local.subauthority_for('resource_types')

    def self.select_options
      authority.all.map do |element|
        [element[:label], element[:id]]
      end
    end

    def self.label(id)
      authority.find(id).fetch('term')
    end

    def self.label_from_alt(alt)
      alt.downcase!
      label = authority.all.map do |element|
        element[:label] if element[:label].downcase == alt || element[:alt_labels].include?(alt)
      end .compact
      label.blank? ? nil : label.first
    end

    ##
    # @param [String, nil] id identifier of the resource type
    #
    # @return [String] a schema.org type. Gives the default type if `id` is nil.
    def self.microdata_type(id)
      return Hyrax.config.microdata_default_type if id.nil?

      Microdata.fetch("resource_type.#{id}", default: Hyrax.config.microdata_default_type)
    end
  end
end