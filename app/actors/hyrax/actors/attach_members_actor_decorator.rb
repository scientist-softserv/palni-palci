# frozen_string_literal: true

# OVERRIDE Hyrax 3.6.0 to add a reindex job when updating members
module Hyrax
  module Actors
    module AttachMembersActorDecorator
      def update_members(resource:, inserts: [], destroys: [])
        resource.member_ids += inserts.map  { |id| Valkyrie::ID.new(id) }
        resource.member_ids -= destroys.map { |id| Valkyrie::ID.new(id) }
        ReindexWorksJob.set(wait: 1.minute).perform_later(inserts + destroys)
      end
    end
  end
end

Hyrax::Actors::AttachMembersActor.prepend Hyrax::Actors::AttachMembersActorDecorator
