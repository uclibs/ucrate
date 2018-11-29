class AddUcdepartmentToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :ucdepartment, :string
  end
end
