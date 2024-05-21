# frozen_string_literal: true

module Wings
  # OVERRIDE Hyrax v3.6.0 to backport a bug fix from v5.0.1.
  # This override is no longer needed when Hyrax's version is >= v5.0.1
  #
  # Work forms were throwing 504 time out errors because large AdminSets
  # being queried by Hyrax#query_service were loading all of their members.
  #
  # @see https://github.com/samvera/hyrax/commit/75312ee
  module ModelTransformerDecorator
    # OVERRIDE: Remove :member_ids
    def additional_attributes
      { :id => pcdm_object.id,
        :created_at => pcdm_object.try(:create_date),
        :updated_at => pcdm_object.try(:modified_date),
        ::Valkyrie::Persistence::Attributes::OPTIMISTIC_LOCK => lock_token }
    end
  end
end

Wings::ModelTransformer.prepend(Wings::ModelTransformerDecorator)
