# frozen_string_literal: true

# Override Hyrax 2.6 ot change depostied_workflow_state, hand roll pagination
module Hyrax
  module Admin
    # Presents a list of works in workflow
    class WorkflowsController < ::ApplicationController
      before_action :ensure_authorized!
      with_themed_layout 'dashboard'
      class_attribute :deposited_workflow_state_name

      # Works that are in this workflow state (see
      # workflow json template) are excluded from the
      # status list and display in the "Published" tab
      self.deposited_workflow_state_name = 'deposited'

      def index
        add_breadcrumb t('hyrax.controls.home'), root_path
        add_breadcrumb t('hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
        add_breadcrumb t('hyrax.admin.sidebar.tasks'), '#'
        add_breadcrumb t('hyrax.admin.sidebar.workflow_review'), request.path
      end

      def under_review
        search_term = "-workflow_state_name_ssim:#{deposited_workflow_state_name}"
        @status_list = Hyrax::Workflow::StatusListService.new(self,
                                                              search_term,
                                                              page,
                                                              per_page,
                                                              order,
                                                              search)
        respond_to do |format|
          format.json { render json: format_data(@status_list) }
        end
      end

      def approved
        search_term = "workflow_state_name_ssim:#{deposited_workflow_state_name}"
        @published_list = Hyrax::Workflow::StatusListService.new(self,
                                                                 search_term,
                                                                 page,
                                                                 per_page,
                                                                 order,
                                                                 search)

        respond_to do |format|
          format.json { render json: format_data(@published_list) }
        end
      end

      private

        def ensure_authorized!
          authorize! :review, :submissions
        end

        def search
          params['search']['value'] if params["search"]&.[]("value").present?
        end

        def per_page
          params[:length].to_i
        end

        def order
          column_to_solr_order(params["order"])
        end

        # convert offset to page number
        def page
          (params[:start].to_i / params[:length].to_i) + 1
        end

        def format_data(data)
          result = data.solr_documents.map do |document|
            {
              title: view_context.link_to(document, [main_app, document]),
              depositor: document.depositor,
              submission_date: document.date_uploaded,
              last_modified_date: document.date_modified,
              status: document.workflow_state
            }
          end
          {
            data: result,
            recordsTotal: data.total_items,
            recordsFiltered: data.total_items
          }
        end

        def column_to_solr_order(order)
          lookup = [
            "title_ssim",
            "creator_ssim",
            "date_uploaded_dtsi",
            "date_modified_dtsi",
            "workflow_state_name_ssim"
          ]
          ordered_field = lookup[order["0"]["column"].to_i]
          return nil unless ordered_field
          direction = order["0"]["dir"] || "asc"
          "#{ordered_field} #{direction}"
        end
    end
  end
end
