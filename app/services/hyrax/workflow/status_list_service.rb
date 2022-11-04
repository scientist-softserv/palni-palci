# frozen_string_literal: true

# Override from Hyrax 2.6, hand roll pagination
module Hyrax
  module Workflow
    # Finds a list of works that we can perform a workflow action on
    class StatusListService
      # @param context [#current_user, #logger]
      # @param filter_condition [String] a solr filter
      def initialize(context, filter_condition, page = 1, per_page = 1000, order = nil, query = nil)
        @context = context
        @filter_condition = filter_condition
        @page = page
        @per_page = per_page
        @rows = per_page
        @offset = (page - 1) * per_page
        @order = order
        @query = query
      end

      attr_reader :context

      # @return [Array<StatusRow>] a list of results that the given user can take action on.
      def each
        return enum_for(:find_each) unless block_given?
        solr_documents.each do |doc|
          yield doc
        end
      end

      def user
        context.current_user
      end

      def total_items
        @work_relation&.search_result&.[]('response')&.[]('numFound') || 0
      end

      def total_pages
        (total_items.to_f / @per_page).ceil
      end

      def current_page
        @page
      end

      def limit_value; end

      # @return [Hash<String,SolrDocument>] a hash of id to solr document
      def solr_documents
        search_solr.map { |result| ::SolrDocument.new(result) }
      end

      private

        delegate :logger, to: :context

        def search_solr # rubocop:disable Metrics/MethodLength
          actionable_roles = roles_for_user
          logger.debug("Actionable roles for #{user.user_key} are #{actionable_roles}")
          return [] if actionable_roles.empty?
          @work_relation = WorkRelation.new
          # TODO: df list is hard coded, should come from blacklight to handle the general case
          @work_relation.search_with_conditions(query(actionable_roles),
                                                rows: @rows,
                                                start: @offset,
                                                sort: @order,
                                                method: :post,
                                                paginate: true,
                                                df: %w[title_tesim
                                                       alternative_title_tesim
                                                       date_modified_tesim
                                                       date_created_tesim
                                                       date_uploaded_tesim
                                                       file_format_tesim
                                                       all_text_timv])
        end

        def query(actionable_roles)
          q = ["{!terms f=actionable_workflow_roles_ssim}#{actionable_roles.join(',')}",
               @filter_condition]
          q = [@query] + q if @query.present?
          q
        end

        # @return [Array<String>] the list of workflow-role combinations this user has
        def roles_for_user
          Sipity::Workflow.all.flat_map do |wf|
            workflow_roles_for_user_and_workflow(wf).map do |wf_role|
              "#{wf.permission_template.source_id}-#{wf.name}-#{wf_role.role.name}"
            end
          end
        end

        # @param workflow [Sipity::Workflow]
        # @return [ActiveRecord::Relation<Sipity::WorkflowRole>]
        def workflow_roles_for_user_and_workflow(workflow)
          Hyrax::Workflow::PermissionQuery.scope_processing_workflow_roles_for_user_and_workflow(user: user,
                                                                                                 workflow: workflow)
        end
    end
  end
end
