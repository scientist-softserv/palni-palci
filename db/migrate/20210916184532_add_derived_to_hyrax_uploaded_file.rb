class AddDerivedToHyraxUploadedFile < ActiveRecord::Migration[5.2]
  def change
    unless column_exists?
      add_column :uploaded_files, :derived, :boolean, default: false
    end
  end
end
