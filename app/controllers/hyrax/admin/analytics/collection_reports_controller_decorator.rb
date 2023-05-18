# frozen_string_literal: true

# OVERRIDE: Hyrax hyrax-v3-5-0 file to create and use #present_collections so that we stop showing deleted collections
# on the collections analytics page

module Hyrax
  module Admin
    module Analytics
      module CollectionReportsControllerDecorator
        def index
          return unless Hyrax.config.analytics?

          @pageviews = Hyrax::Analytics.daily_events('collection-page-view')
          @work_page_views = Hyrax::Analytics.daily_events('work-in-collection-view')
          @downloads = Hyrax::Analytics.daily_events('work-in-collection-download')
          @all_top_collections = Hyrax::Analytics.top_events('work-in-collection-view', date_range)
          present_collections = present_collections(@all_top_collections)
          @top_collections = paginate(present_collections, rows: 10)
          @top_downloads = Hyrax::Analytics.top_events('work-in-collection-download', date_range)
          @top_collection_pages = Hyrax::Analytics.top_events('collection-page-view', date_range)
          respond_to do |format|
            format.html
            format.csv { export_data }
          end
        end

        private

          def present_collections(all_top_collections)
            # filter out collections that have been deleted or are otherwise not present
            all_top_collections.select do |col|
              begin
                Collection.find(col[0]).present?
              rescue StandardError
                # account for errors such as ActiveFedora::ObjectNotFoundError, Ldp::Gone, etc.
                next
              end
            end
          end
      end
    end
  end
end

Hyrax::Admin::Analytics::CollectionReportsController.prepend(Hyrax::Admin::Analytics::CollectionReportsControllerDecorator)
