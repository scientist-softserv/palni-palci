# frozen_string_literal: true

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

      ##
      # We have encountered some semblance of missing data, we've thrown that via an exception, and we're
      # handling that missing data by presenting the error to the end user.
      # @param [Exception]
      #
      def render_not_found(error)
        render json: { error: error.message }, status: 404
      end
      rescue_from Sushi::NotFoundError, with: :render_not_found

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
      @report = Sushi::ItemReport.new(params, account: current_account)
      render json: @report
    end

    def platform_report
      @report = Sushi::PlatformReport.new(params, account: current_account)
      render json: @report
    end

    def platform_usage
      @report = Sushi::PlatformUsageReport.new(params, account: current_account)
      render json: @report
    end

    def server_status
      @status = Sushi::ServerStatus.new(account: current_account).server_status
      render json: @status
    end

    def report_list
      @report = Sushi::ReportList.new
      render json: @report
    end
  end
end
