class AddDerivedToHyraxUploadedFile < ActiveRecord::Migration[5.2]
  def change
    add_column :uploaded_files, :derived, :boolean, default: false
  end
end
