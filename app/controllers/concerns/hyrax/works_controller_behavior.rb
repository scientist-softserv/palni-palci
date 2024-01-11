# frozen_string_literal: true

# OVERRIDE: Hyrax 3.4.0 to add inject_show_theme_views - Hyku theming and correct hostname of manifests
# OVERRIDE: Hyrax 3.4.0 to add Hyrax IIIF AV
require 'iiif_manifest'

# rubocop:disable Metrics/ModuleLength
module Hyrax
  module WorksControllerBehavior
    extend ActiveSupport::Concern
    include Blacklight::Base
    include Blacklight::AccessControls::Catalog

    # Adds behaviors for hyrax-iiif_av plugin and provides #manifest and #iiif_manifest_builder
    include Hyrax::IiifAv::ControllerBehavior

    included do
      with_themed_layout :decide_layout
      copy_blacklight_config_from(::CatalogController)

      class_attribute :_curation_concern_type, :show_presenter, :work_form_service, :search_builder_class
      class_attribute :iiif_manifest_builder, instance_accessor: false
      self.show_presenter = Hyku::WorkShowPresenter
      self.work_form_service = Hyrax::WorkFormService
      self.search_builder_class = WorkSearchBuilder
      # Set to nil for the #iiif_manifest_builder (provided by Hyrax::IiifAv) to work
      self.iiif_manifest_builder = nil

      attr_accessor :curation_concern
      helper_method :curation_concern, :contextual_path

      rescue_from WorkflowAuthorizationException, with: :render_unavailable
      # add around action to load theme show page views
      around_action :inject_show_theme_views, except: :delete # rubocop:disable Rails/LexicallyScopedActionFilter
    end

    class_methods do
      def curation_concern_type=(curation_concern_type)
        load_and_authorize_resource class: curation_concern_type,
                                    instance_name: :curation_concern,
                                    except: %i[show file_manager inspect_work manifest]

        # Load the fedora resource to get the etag.
        # No need to authorize for the file manager, because it does authorization via the presenter.
        load_resource class: curation_concern_type, instance_name: :curation_concern, only: :file_manager

        self._curation_concern_type = curation_concern_type
        # We don't want the breadcrumb action to occur until after the concern has
        # been loaded and authorized
        before_action :save_permissions, only: :update # rubocop:disable Rails/LexicallyScopedActionFilter
        prepend_before_action :store_location, only: :show
      end

      def curation_concern_type
        _curation_concern_type
      end

      def cancan_resource_class
        Hyrax::ControllerResource
      end
    end

    def new
      @admin_set_options = available_admin_sets
      # TODO: move these lines to the work form builder in Hyrax
      curation_concern.depositor = current_user.user_key
      curation_concern.admin_set_id = admin_set_id_for_new
      build_form
    end

    def create
      case curation_concern
      when ActiveFedora::Base
        original_input_params_for_form = params[hash_key_for_curation_concern].deep_dup
        actor.create(actor_environment) ? after_create_response : after_create_error(curation_concern.errors, original_input_params_for_form)
      else
        create_valkyrie_work
      end
    end

    # Finds a solr document matching the id and sets @presenter
    # @raise CanCan::AccessDenied if the document is not found or the user doesn't have access to it.
    def show
      @user_collections = user_collections

      # Ensures that the user does not get redirected back to /admin/workflows after approving or rejecting a work
      # when they did not come from that route
      # see: app/controllers/hyrax/admin/workflows_controller_decorator.rb
      #      app/controllers/hyrax/workflow_actions_controller_decorator.rb
      session.delete(:from_admin_workflows) unless request.referer&.include?(admin_workflows_path)

      respond_to do |wants|
        wants.html { presenter && parent_presenter }
        wants.json do
          # load @curation_concern manually because it's skipped for html
          @curation_concern = Hyrax.query_service.find_by(alternate_identifier: params[:id])
          curation_concern # This is here for authorization checks (we could add authorize! but let's use the same method for CanCanCan)
          render :show, status: :ok
        end
        additional_response_formats(wants)
        wants.ttl { render body: presenter.export_as_ttl, mime_type: Mime[:ttl] }
        wants.jsonld { render body: presenter.export_as_jsonld, mime_type: Mime[:jsonld] }
        wants.nt { render body: presenter.export_as_nt, mime_type: Mime[:nt] }
      end
    end
    # rubocop:enable Metrics/AbcSize

    def edit
      @admin_set_options = available_admin_sets
      build_form
    end

    def update
      case curation_concern
      when ActiveFedora::Base
        actor.update(actor_environment) ? after_update_response : after_update_error(curation_concern.errors)
      else
        update_valkyrie_work
      end
    end

    def destroy
      case curation_concern
      when ActiveFedora::Base
        title = curation_concern.to_s
        env = Actors::Environment.new(curation_concern, current_ability, {})
        return unless actor.destroy(env)
        Hyrax.config.callback.run(:after_destroy, curation_concern.id, current_user, warn: false)
      else
        transactions['work_resource.destroy']
          .with_step_args('work_resource.delete' => { user: current_user })
          .call(curation_concern)
          .value!

        title = Array(curation_concern.title).first
      end

      after_destroy_response(title)
    end

    def file_manager
      @form = Forms::FileManagerForm.new(curation_concern, current_ability)
    end

    def inspect_work
      raise Hydra::AccessDenied unless current_ability.admin?
      presenter
    end

    def json_manifest
      iiif_manifest_builder.manifest_for(presenter: iiif_manifest_presenter)
    end

    private

      def iiif_manifest_presenter
        IiifManifestPresenter.new(search_result_document(id: params[:id])).tap do |p|
          p.hostname = request.hostname
          p.ability = current_ability
        end
      end

      def user_collections
        collections_service.search_results(:deposit)
      end

      def collections_service
        Hyrax::CollectionsService.new(self)
      end

      def admin_set_id_for_new
        Hyrax::AdminSetCreateService.find_or_create_default_admin_set.id.to_s
      end

      def build_form
        @form = work_form_service.build(curation_concern, current_ability, self)
      end

      def actor
        @actor ||= Hyrax::CurationConcern.actor
      end

      ##
      # @return [#errors]
      def create_valkyrie_work
        form = build_form
        return after_create_error(form_err_msg(form)) unless form.validate(params[hash_key_for_curation_concern])

        result =
          transactions['change_set.create_work']
          .with_step_args(
            'work_resource.add_to_parent' => { parent_id: params[:parent_id], user: current_user },
            'work_resource.add_file_sets' => { uploaded_files: uploaded_files, file_set_params: params[hash_key_for_curation_concern][:file_set] },
            'change_set.set_user_as_depositor' => { user: current_user },
            'work_resource.change_depositor' => { user: ::User.find_by_user_key(form.on_behalf_of) }
          )
          .call(form)
        @curation_concern = result.value_or { return after_create_error(transaction_err_msg(result)) }
        after_create_response
      end

      def update_valkyrie_work
        form = build_form
        return after_update_error(form_err_msg(form)) unless form.validate(params[hash_key_for_curation_concern])
        result =
          transactions['change_set.update_work']
          .with_step_args('work_resource.add_file_sets' => { uploaded_files: uploaded_files, file_set_params: params[hash_key_for_curation_concern][:file_set] },
                          'work_resource.update_work_members' => { work_members_attributes: work_members_attributes })
          .call(form)
        @curation_concern = result.value_or { return after_update_error(transaction_err_msg(result)) }
        after_update_response
      end

      def work_members_attributes
        params[hash_key_for_curation_concern][:work_members_attributes]&.permit!&.to_h
      end

      def form_err_msg(form)
        form.errors.messages.values.flatten.to_sentence
      end

      def transaction_err_msg(result)
        result.failure.first
      end

      def presenter
        @presenter ||= show_presenter.new(search_result_document(id: params[:id]), current_ability, request)
      end

      def parent_presenter
        return @parent_presenter unless params[:parent_id]

        @parent_presenter ||=
          show_presenter.new(search_result_document(id: params[:parent_id]), current_ability, request)
      end

      # Include 'hyrax/base' in the search path for views, while prefering
      # our local paths. Thus we are unable to just override `self.local_prefixes`
      def _prefixes
        @_prefixes ||= super + ['hyrax/base']
      end

      def actor_environment
        Actors::Environment.new(curation_concern, current_ability, attributes_for_actor)
      end

      def hash_key_for_curation_concern
        _curation_concern_type.model_name.param_key
      end

      def contextual_path(presenter, parent_presenter)
        ::Hyrax::ContextualPath.new(presenter, parent_presenter).show
      end

      # @deprecated
      def curation_concern_from_search_results
        Deprecation.warn("'##{__method__}' will be removed in Hyrax 4.0.  " \
          "Instead, use '#search_result_document'.")
        search_params = params.deep_dup
        search_params.delete :page
        search_result_document(search_params)
      end

      ##
      # Only returns unsuppressed documents the user has read access to
      #
      # @api public
      #
      # @param search_params [ActionController::Parameters] this should
      #   include an :id key, but based on implementation and use of the
      #   WorkSearchBuilder, it need not.
      #
      # @return [SolrDocument]
      #
      # @raise [WorkflowAuthorizationException] when the object is not
      #   found via the search builder's search logic BUT the object is
      #   suppressed AND the user can read it (Yeah, it's confusing but
      #   after a lot of debugging that's the logic)
      #
      # @raise [CanCan::AccessDenied] when the object is not found via
      #   the search builder's search logic BUT the object is not
      #   supressed OR not readable by the user (Yeah.)
      #
      # @note This is Jeremy, I have suspicions about the first line of
      #   this comment (eg, "Only return unsuppressed...").  The
      #   reason is that I've encounter situations in the specs
      #   where the document_list is empty but if I then query Solr
      #   for the object by ID, I get a document that is NOT
      #   suppressed AND can be read.  In other words, I believe
      #   there is more going on in the search_results method
      #   (e.g. a filter is being applied that is beyond what the
      #   comment indicates)
      #
      # @see #document_not_found!
      def search_result_document(search_params)
        _, document_list = search_results(search_params)
        return document_list.first unless document_list.empty?
        document_not_found!
      end

      def document_not_found!
        doc = ::SolrDocument.find(params[:id])
        raise WorkflowAuthorizationException if doc.suppressed? && current_ability.can?(:read, doc)
        raise CanCan::AccessDenied.new(nil, :show)
      end

      def render_unavailable
        message = I18n.t("hyrax.workflow.unauthorized")
        respond_to do |wants|
          wants.html do
            unavailable_presenter
            flash[:notice] = message
            render 'unavailable', status: :unauthorized
          end
          wants.json { render plain: message, status: :unauthorized }
          additional_response_formats(wants)
          wants.ttl { render plain: message, status: :unauthorized }
          wants.jsonld { render plain: message, status: :unauthorized }
          wants.nt { render plain: message, status: :unauthorized }
        end
      end

      def unavailable_presenter
        @presenter ||= show_presenter.new(::SolrDocument.find(params[:id]), current_ability, request)
      end

      def decide_layout
        layout = case action_name
                 when 'show'
                   '1_column'
                 else
                   'dashboard'
                 end
        File.join(theme, layout)
      end

      ##
      # @todo should the controller know so much about browse_everything?
      #   hopefully this can be refactored to be more reusable.
      #
      # Add uploaded_files to the parameters received by the actor.
      def attributes_for_actor
        raw_params = params[hash_key_for_curation_concern]
        attributes = if raw_params
                       work_form_service.form_class(curation_concern).model_attributes(raw_params)
                     else
                       {}
                     end

        # If they selected a BrowseEverything file, but then clicked the
        # remove button, it will still show up in `selected_files`, but
        # it will no longer be in uploaded_files. By checking the
        # intersection, we get the files they added via BrowseEverything
        # that they have not removed from the upload widget.
        uploaded_files = params.fetch(:uploaded_files, [])
        selected_files = params.fetch(:selected_files, {}).values
        browse_everything_urls = uploaded_files &
                                 selected_files.map { |f| f[:url] }

        # we need the hash of files with url and file_name
        browse_everything_files = selected_files
                                  .select { |v| uploaded_files.include?(v[:url]) }
        attributes[:remote_files] = browse_everything_files
        # Strip out any BrowseEverthing files from the regular uploads.
        attributes[:uploaded_files] = uploaded_files -
                                      browse_everything_urls
        attributes
      end

      def after_create_response
        respond_to do |wants|
          wants.html do
            # Calling `#t` in a controller context does not mark _html keys as html_safe
            flash[:notice] = view_context.t('hyrax.works.create.after_create_html', application_name: view_context.application_name)
            redirect_to [main_app, curation_concern]
          end
          wants.json { render :show, status: :created, location: polymorphic_path([main_app, curation_concern]) }
        end
      end

      def format_error_messages(errors)
        errors.messages.map do |field, messages|
          field_name = field.to_s.humanize
          messages.map { |message| "#{field_name} #{message.sub(/^./, &:downcase)}" }
        end.flatten.join("\n")
      end

      def after_create_error(errors, original_input_params_for_form = nil)
        respond_to do |wants|
          wants.html do
            flash[:error] = format_error_messages(errors)
            rebuild_form(original_input_params_for_form) if original_input_params_for_form.present?
            render 'new', status: :unprocessable_entity
          end
          wants.json { render_json_response(response_type: :unprocessable_entity, options: { errors: errors }) }
        end
      end

      # Creating a form object that can re-render most of the submitted parameters.
      # Required for ActiveFedora::Base objects only.
      def rebuild_form(original_input_params_for_form)
        build_form
        @form = Hyrax::Forms::FailedSubmissionFormWrapper
                .new(form: @form,
                     input_params: original_input_params_for_form)
      end

      def after_update_response
        return redirect_to hyrax.confirm_access_permission_path(curation_concern) if permissions_changed? && concern_has_file_sets?

        respond_to do |wants|
          wants.html { redirect_to [main_app, curation_concern], notice: "Work \"#{curation_concern}\" successfully updated." }
          wants.json { render :show, status: :ok, location: polymorphic_path([main_app, curation_concern]) }
        end
      end

      def after_update_error(errors)
        respond_to do |wants|
          wants.html do
            flash[:error] = format_error_messages(errors)
            build_form unless @form.is_a? Hyrax::ChangeSet
            render 'edit', status: :unprocessable_entity
          end
          wants.json { render_json_response(response_type: :unprocessable_entity, options: { errors: errors }) }
        end
      end

      def after_destroy_response(title)
        respond_to do |wants|
          wants.html { redirect_to hyrax.my_works_path, notice: "Deleted #{title}" }
          wants.json { render_json_response(response_type: :deleted, message: "Deleted #{curation_concern.id}") }
        end
      end

      def additional_response_formats(format)
        format.endnote do
          send_data(presenter.solr_document.export_as_endnote,
                    type: "application/x-endnote-refer",
                    filename: presenter.solr_document.endnote_filename)
        end
      end

      def store_action
        return unless request.get?
        if (!request.xhr?) # don't store ajax calls
          cookies[:reshare_url] = { value: request.fullpath, same_site: :none, secure: true }
        end
      end

      def save_permissions
        @saved_permissions =
          case curation_concern
          when ActiveFedora::Base
            curation_concern.permissions.map(&:to_hash)
          else
            Hyrax::AccessControl.for(resource: curation_concern).permissions
          end
      end

      def permissions_changed?
        @saved_permissions !=
          case curation_concern
          when ActiveFedora::Base
            curation_concern.permissions.map(&:to_hash)
          else
            Hyrax::AccessControl.for(resource: curation_concern).permissions
          end
      end

      def concern_has_file_sets?
        case curation_concern
        when ActiveFedora::Common
          curation_concern.file_sets.present?
        else
          Hyrax.custom_queries.find_child_file_set_ids(resource: curation_concern).any?
        end
      end

      def uploaded_files
        UploadedFile.find(params.fetch(:uploaded_files, []))
      end

      def available_admin_sets
        # only returns admin sets in which the user can deposit
        admin_set_results = Hyrax::AdminSetService.new(self).search_results(:deposit)

        # get all the templates at once, reducing query load
        templates = PermissionTemplate.where(source_id: admin_set_results.map(&:id)).to_a

        admin_sets = admin_set_results.map do |admin_set_doc|
          template = templates.find { |temp| temp.source_id == admin_set_doc.id.to_s }

          ## OVERRIDE Hyrax v3.4.2
          # Removes a short-circuit that allowed users with manage access to
          # the given permission_template to always be able to edit a record's sharing
          # (i.e. the "Sharing" tab in forms).
          #
          # We remove this because there is currently a bug in Hyrax where, if the
          # workflow does not allow access grants, changes to a record's sharing
          # are not being persisted, leading to a confusing UX.
          # @see https://github.com/samvera/hyrax/issues/5904
          #
          # TEMPORARY: This override should be removed when the bug is resolved in
          # upstream Hyrax and brought into this project.
          #
          # determine if sharing tab should be visible
          sharing = !!template&.active_workflow&.allows_access_grant? # rubocop:disable Style/DoubleNegation

          AdminSetSelectionPresenter::OptionsEntry
            .new(admin_set: admin_set_doc, permission_template: template, permit_sharing: sharing)
        end

        AdminSetSelectionPresenter.new(admin_sets: admin_sets)
      end

      # added to prepend the show theme views into the view_paths
      def inject_show_theme_views
        if show_page_theme && show_page_theme != 'default_show'
          original_paths = view_paths
          show_theme_view_path = Rails.root.join('app', 'views', "themes", show_page_theme.to_s)
          prepend_view_path(show_theme_view_path)
          yield
          view_paths=(original_paths) # rubocop:disable Lint/UselessAssignment
          # rubocop:enable Lint/UselessAssignment, Layout/SpaceAroundOperators, Style/RedundantParentheses
        else
          yield
        end
      end
  end
end
# rubocop:enable Metrics/ModuleLength
