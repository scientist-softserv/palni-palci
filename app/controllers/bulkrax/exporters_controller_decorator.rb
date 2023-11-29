# frozen_string_literal: true

# Override Bulkrax main (at v5.3.0) to limit access to only user's own exporters
module Bulkrax
  module ExportersControllerDecorator
    def index
      # NOTE: We're paginating this in the browser.
      @exporters = Exporter.order(created_at: :desc)
      @exporters = @exporters.where(user: current_user) unless current_ability.admin?
      @exporters = @exporters.all

      add_exporter_breadcrumbs if defined?(::Hyrax)
    end

    private

      def check_permissions
        raise CanCan::AccessDenied unless current_ability.can_export_works?
        return true if current_ability.admin?
        return true unless params.key?(:id)
        return true if Importer.where(id: params[:id], user: current_user).exists?
        raise CanCan::AccessDenied
      end
  end
end

Bulkrax::ExportersController.prepend(Bulkrax::ExportersControllerDecorator)
