# frozen_string_literal: true

# OVERRIDE: Hyrax hyrax-v3-5-0 file to create and use #present_collections so that we stop showing deleted collections
# on the collections analytics page

module Hyrax
  module Admin
    module Analytics
      class CollectionReportsControllerDecorator
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

        def show
          return unless Hyrax.config.analytics?
          @document = ::SolrDocument.find(params[:id])
          @pageviews = Hyrax::Analytics.daily_events_for_id(@document.id, 'collection-page-view')
          @work_page_views = Hyrax::Analytics.daily_events_for_id(@document.id, 'work-in-collection-view')
          @uniques = Hyrax::Analytics.unique_visitors_for_id(@document.id)
          @downloads = Hyrax::Analytics.daily_events_for_id(@document.id, 'work-in-collection-download')
          respond_to do |format|
            format.html
            format.csv { export_data }
          end
        end

        private

        # rubocop:disable Metrics/MethodLength
        def export_data
          csv_row = CSV.generate do |csv|
            csv << ["Name", "ID", "View of Works In Collection", "Downloads of Works In Collection", "Collection Page Views"]
            @all_top_collections.each do |collection|
              document = begin
                           ::SolrDocument.find(collection[0])
                         rescue
                           "Collection deleted"
                         end
              download_match = @top_downloads.detect { |a, _b| a == collection[0] }
              download_count = download_match ? download_match[1] : 0
              collection_match = @top_collection_pages.detect { |a, _b| a == collection[0] }
              collection_count = collection_match ? collection_match[1] : 0
              csv << [document, collection[0], collection[1], download_count, collection_count]
            end
          end
          send_data csv_row, filename: "#{@start_date}-#{@end_date}-collections.csv"
        end
        # rubocop:enable Metrics/MethodLength

        def present_collections(all_top_collections)
          # filter out collections that have been deleted or are otherwise not present
          all_top_collections.select do |col|
            begin
              Collection.find(col[0]).present?
            rescue ActiveFedora::ObjectNotFoundError
              next
            end
          end
        end
      end
    end
  end
end
