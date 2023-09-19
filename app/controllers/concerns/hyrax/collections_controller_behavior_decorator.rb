# frozen_string_literal: true

# OVERRIDE Hyrax v3.6.0 to sort subcollections by title

module Hyrax
  module CollectionsControllerBehaviorDecorator
    def load_member_subcollections
      super
      return if @subcollection_docs.blank?

      @subcollection_docs.sort_by! { |doc| doc.title.first&.downcase }
    end

    def show
      # OVERRIDE Hyrax 3.6.0 to default sort by title instead of relevance
      params[:sort] ||= "title_ssi asc"

      super
    end
  end
end

Hyrax::CollectionsControllerBehavior.prepend Hyrax::CollectionsControllerBehaviorDecorator
