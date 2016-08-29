class UserFirstAndLastNames < ActiveRecord::Migration
  def change
    add_column User.table_name, :first_name, :string
    add_column User.table_name, :last_name, :string
  end
end
