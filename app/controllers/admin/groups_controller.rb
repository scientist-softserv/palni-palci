module Admin
  # OVERRIDE from AdminController inheretence for user roles authorization
  class GroupsController < ApplicationController
    # OVERRIDE: replaced before_action :load_group with the following load_and_authorize_resource
    load_and_authorize_resource class: '::Hyrax::Group', instance_name: :group, only: %i[create edit update remove destroy]
    layout 'hyrax/dashboard'

    def index
      # OVERRIDE: AUTHORIZE A READER ROLE TO ACCESS THE GROUPS INDEX
      authorize! :read, Hyrax::Group
      add_breadcrumb t(:'hyrax.controls.home'), root_path
      add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
      add_breadcrumb t(:'hyku.admin.groups.title.index'), admin_groups_path
      @groups = Hyrax::Group.search(params[:q]).page(page_number).per(page_size)
    end

    def new
      add_breadcrumb t(:'hyrax.controls.home'), root_path
      add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
      add_breadcrumb t(:'hyku.admin.groups.title.new'), new_admin_group_path
      @group = Hyrax::Group.new
    end

    def create
      new_group = Hyrax::Group.new(group_params)
      new_group.name = group_params[:humanized_name].gsub(" ", "_").downcase
      if new_group.save
        redirect_to admin_groups_path, notice: t('hyku.admin.groups.flash.create.success', group: new_group.name)
      elsif new_group.invalid?
        redirect_to new_admin_group_path, alert: t('hyku.admin.groups.flash.create.invalid')
      else
        redirect_to new_admin_group_path, flash: { error: t('hyku.admin.groups.flash.create.failure') }
      end
    end

    def edit
      add_breadcrumb t(:'hyrax.controls.home'), root_path
      add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
      add_breadcrumb t(:'hyku.admin.groups.title.edit'), edit_admin_group_path
    end

    def update
      @group.name = group_params[:humanized_name].gsub(" ", "_").downcase
      if @group.update(group_params)
        redirect_to admin_groups_path, notice: t('hyku.admin.groups.flash.update.success', group: @group.humanized_name)
      else
        redirect_to edit_admin_group_path(@group), flash: {
          error: t('hyku.admin.groups.flash.update.failure', group: @group.humanized_name)
        }
      end
    end

    def remove
      add_breadcrumb t(:'hyrax.controls.home'), root_path
      add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
      add_breadcrumb t(:'hyku.admin.groups.title.edit'), edit_admin_group_path
      add_breadcrumb t(:'hyku.admin.groups.title.remove'), request.path
    end

    def destroy
      if @group.destroy
        redirect_to admin_groups_path, notice: t('hyku.admin.groups.flash.destroy.success', group: @group.humanized_name)
      else
        logger.error("Hyrax::Group id:#{@group.id} could not be destroyed")
        redirect_to admin_groups_path flash: { error: t('hyku.admin.groups.flash.destroy.failure', group: @group.humanized_name) }
      end
    end

    private

      def group_params
        params.require(:group).permit(:name, :humanized_name, :description)
      end

      def page_number
        params.fetch(:page, 1).to_i
      end

      def page_size
        params.fetch(:per, 10).to_i
      end
  end
end
