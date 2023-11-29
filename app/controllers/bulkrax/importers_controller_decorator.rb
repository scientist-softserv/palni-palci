# frozen_string_literal: true

# Override Bulkrax main (at v5.3.0) to limit access to only user's own importers
module Bulkrax
  module ImportersControllerDecorator
    # GET /importers
    def index
      # NOTE: We're paginating this in the browser.
      @importers = Importer.order(created_at: :desc)
      @importers = @importers.where(user: current_user) unless current_ability.admin?
      @importers = @importers.all

      if api_request?
        json_response('index')
      elsif defined?(::Hyrax)
        add_importer_breadcrumbs
      end
    end

    private

      def check_permissions
        raise CanCan::AccessDenied unless current_ability.can_import_works?
        return true if current_ability.admin?
        return true unless params.key?(:id)
        return true if Importer.where(id: params[:id], user: current_user).exists?
        raise CanCan::AccessDenied
      end
  end
end

Bulkrax::ImportersController.prepend(Bulkrax::ImportersControllerDecorator)
