# frozen_string_literal: true

# Add ability to mark environment as from bulk import
module Bulkrax
  module ObjectFactoryDecorator
    # @param [Hash] attrs the attributes to put in the environment
    # @return [Hyrax::Actors::Environment]
    def environment(attrs)
      Hyrax::Actors::Environment.new(object, Ability.new(@user), attrs, true)
    end

    # TODO: Verify and remove this once Bulkrax is updated 5.4.1 over greater and this is no longer needed
    def search_by_identifier
      # ref: https://github.com/samvera-labs/bulkrax/issues/866
      # ref:https://github.com/samvera-labs/bulkrax/issues/867
      # work_index = ::ActiveFedora.index_field_mapper.solr_name(work_identifier, :facetable)
      work_index = work_identifier
      query = { work_index =>
                source_identifier_value }
      # Query can return partial matches (something6 matches both something6 and something68)
      # so we need to weed out any that are not the correct full match. But other items might be
      # in the multivalued field, so we have to go through them one at a time.
      match = klass.where(query).detect { |m| m.send(work_identifier).include?(source_identifier_value) }
      return match if match
    end
  end
end

::Bulkrax::ObjectFactory.prepend(Bulkrax::ObjectFactoryDecorator)
