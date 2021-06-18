# OVERRIDE FILE from Hyrax v2.9.0
module Hyrax
  module Admin
    module UsersControllerBehavior
      extend ActiveSupport::Concern
      include Blacklight::SearchContext
      included do
        with_themed_layout 'dashboard'
      end

      # Display admin menu list of users
      def index
        # OVERRIDE: AUTHORIZE A READER ROLE TO ACCESS THE USERS INDEX 
        authorize! :read, ::User
        add_breadcrumb t(:'hyrax.controls.home'), root_path
        add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
        add_breadcrumb t(:'hyrax.admin.users.index.title'), hyrax.admin_users_path
        @presenter = Hyrax::Admin::UsersPresenter.new
      end

    end
  end
end
