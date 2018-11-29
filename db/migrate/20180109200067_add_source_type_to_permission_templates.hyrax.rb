class AddSourceTypeToPermissionTemplates < ActiveRecord::Migration[5.0]
  def change
    add_column :permission_templates, :source_type, :string
  end
end
