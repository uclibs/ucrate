class AddRdPageToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :rd_page, :string
  end
end
