module Hyrax
  module Admin
    class AppearancesController < ApplicationController
      before_action :require_permissions
      with_themed_layout 'dashboard'
      class_attribute :form_class
      self.form_class = Hyrax::Forms::Admin::Appearance

      def show
        #TODO make selected font the font that show in select box
        #TODO add body and headline font to the import url
        
        @fonts =  []
        add_breadcrumb t(:'hyrax.controls.home'), root_path
        add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
        add_breadcrumb t(:'hyrax.admin.sidebar.configuration'), '#'
        add_breadcrumb t(:'hyrax.admin.sidebar.appearance'), request.path
        @form = form_class.new
      end

      def update
        form_class.new(update_params).update!
        # raise "fun"
        # font_names = update_params['body_font']
        # google_fonts_import_tag(*fonts)
        redirect_to({ action: :show }, notice: t('.flash.success'))
      end

      private

        def update_params
          params.require(:admin_appearance).permit(form_class.permitted_params)
        end

        def require_permissions
          authorize! :update, :appearance
        end
    end
  end
end

        