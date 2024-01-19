# frozen_string_literal: true

# OVERRIDE IIIF Print v1.0.0 to call CreateGroupAndAddMembersJob

module IiifPrint
  module Jobs
    module CreateRelationshipsJobDecorator
      private

        def create_relationships(parent:, **)
          super
          CreateGroupAndAddMembersJob.set(wait: 2.minutes).perform_later(parent.id)
        end
    end
  end
end

IiifPrint::Jobs::CreateRelationshipsJob.prepend(IiifPrint::Jobs::CreateRelationshipsJobDecorator)
