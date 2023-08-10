# frozen_string_literal: true

# maybe rename to counter_metrics_controller?
module API
  class SushiController < ApplicationController
    private

      ##
      # We have encountered an error in their request, this might be an invalid date or a missing
      # required parameter.  The end user can adjust the request and try again.
      def render_error_that_is_user_correctable(error)
        render json: { error: error.message }, status: 422
      end
      rescue_from ActionController::ParameterMissing, Sushi::InvalidParameterValue, with: :render_error_that_is_user_correctable

    public

    ##
    # needs to include the following filters: begin & end date, item ID
    #
    #
    # When given an item_id parameter, filter the results to only that item_id.
    #
    # @note We should not need to find the record in ActiveFedora; hopefully we have all we need in
    #       the stats database.
    def item_report
      if params[:item_id]
        # example of the URL with an item_id
        # /api/sushi/r51/reports/ir?item_id=7fdf12a0-b8da-46c6-88dc-64dbb5bc31d7

        render json: { "item_report" => 'hello single item report' }
      else
        # here we would return the JSON that includes all works in the Item Report
        render json: { "item_report" => 'hello all items report' }
      end
    end

    def platform_report
      @report = Sushi::PlatformReport.new(params, account: current_account)
      render json: @report
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
      # Logic to retrieve and list available reports
      render json: { "reports" => 'message' }
    end
  end
end
