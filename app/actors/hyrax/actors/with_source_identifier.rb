# frozen_string_literal: true

module Hyrax
  module Actors
    module WithSourceIdentifier
      def apply_creation_data_to_curation_concern(env)
        apply_source_identifier(env)
        apply_depositor_metadata(env)
        apply_deposit_date(env)
      end

      def apply_source_identifier(env)
        env.curation_concern.source_identifier ||= SecureRandom.uuid
      end
    end
  end
end
