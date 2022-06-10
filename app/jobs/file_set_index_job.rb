class FileSetIndexJob < Hyrax::ApplicationJob
  def perform(file_set_id)
    f = FileSet.find(file_set_id)
    f&.update_index
  end
end
