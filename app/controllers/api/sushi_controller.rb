# frozen_string_literal: true

# maybe rename to counter_metrics_controller?
module API
  class SushiController < ApplicationController

    # needs to include the following filters: begin & end date, item ID
    def get_item_report
      # Need to find the id with
      if params[:item_id]
        #need to figure out how to look at all worktypes for the ID
        #work = GenericWork.find(item_id)
        # here we would return the JSON that only includes the specific work
        render json: { "item_report" => 'hello' }
      else
        # here we would return the JSON that includes all works in the Item Report
        render json: { "item_report" => 'hello2' }
      end
    end

    def get_platform_report
      # Logic to retrieve platform report
      render json: { "platform_report" => 'hi' }
    end

    def get_platform_usage_report
      # Logic to retrieve platform usage report
      render json: { "platform_usage_report" => 'message' }
    end

    def get_status
      render json: { "status" => "ok" }
    end

    def get_members
      # Logic to retrieve members data
      render json: { "members" => 'message' }
    end

    def list_reports
      # Logic to retrieve and list available reports
      render json: { "reports" => 'message' }
    end

    def get_item_report_for_single_item
      # Logic to retrieve item report by id
      render json: { "reports" => 'single item' }
    end

    private

      def sushi_params
        params.permit(:item_id, :report_id)
      end
  end
end
