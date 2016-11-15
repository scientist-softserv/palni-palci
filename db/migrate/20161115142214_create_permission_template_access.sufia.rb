# This migration comes from sufia (originally 20161021180154)
class CreatePermissionTemplateAccess < ActiveRecord::Migration
  def change
    create_table :permission_template_accesses do |t|
      t.references :permission_template, foreign_key: true
      t.string :agent_type
      t.string :agent_id
      t.string :access
      t.timestamps
    end
  end
end
