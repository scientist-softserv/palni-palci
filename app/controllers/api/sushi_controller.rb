# frozen_string_literal: true

module API
  class SushiController < ApplicationController
    # needs to include the following filters: begin & end date, item ID
    def item_report
      if params[:item_id]
        # example of the URL with an item_id
        # /api/sushi/r51/reports/ir?item_id=7fdf12a0-b8da-46c6-88dc-64dbb5bc31d7
        # work_id = params[:item_id]
        # work = ActiveFedora::Base.find(work_id)
        # here we would return the JSON that only includes the specific work
        render json: { "item_report" => 'hello single item report' }
      else
        # here we would return the JSON that includes all works in the Item Report
        render json: { "item_report" => 'hello all items report' }
      end
    end

    def platform_report
      # Logic to retrieve platform report
      render json: { "platform_report" => 'hi' }
    end

    def platform_usage_report
      # Logic to retrieve platform usage report
      render json: { "platform_usage_report" => 'message' }
    end

    def status
      render json: { "status" => "ok" }
    end

    def members
      # Logic to retrieve members data
      render json: { "members" => 'message' }
    end

    def list_reports
      render json: { "reports" => 'all the reports' }
      # render json: Reports::ReportsReport.new.reports_array
    end

    private

      def sushi_params
        params.permit(:item_id, :report_id)
      end
  end
end
