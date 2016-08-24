class TitleAndDescriptionWorkgroups < ActiveRecord::Migration
  def change
  	add_column Workgroup.table_name, :title, :string
  	add_column Workgroup.table_name, :description, :string
  end
end
