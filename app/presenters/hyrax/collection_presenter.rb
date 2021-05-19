# OVERRIDE FILE from Hyrax v2.9.0
#
# Override this class using #class_eval to avoid needing to copy the entire file over from
# the dependency. For more info, see the "Overrides using #class_eval" section in the README.
require_dependency Hyrax::Engine.root.join('app', 'presenters', 'hyrax', 'collection_presenter').to_s

Hyrax::CollectionPresenter.class_eval do
  # OVERRIDE: Add new method to check if a user has permissions to create any works.
  # This is used to restrict who can deposit new works through collections. See
  # app/views/hyrax/dashboard/collections/_show_add_items_actions.html.erb for usage.
  def create_any_work_types?
    create_work_presenter.authorized_models.any?
  end

  # OVERRIDE: Because the only batch operation allowed currently is deleting,
  # change the ability check because not all users who can edit can also destroy.
  #
  # Determine if the user can perform batch operations on this collection.  Currently, the only
  # batch operation allowed is deleting, so this is equivalent to checking if the user can delete
  # the collection determined by criteria...
  # * user must be able to edit the collection to be able to delete it
  # * the collection does not have to be empty
  # @return Boolean true if the user can perform batch actions; otherwise, false
  def allow_batch?
    return true if current_ability.can?(:destroy, solr_document) # OVERRIDE: change :edit to :destroy
    false
  end
end