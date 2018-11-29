class AddProfileUpdateNotRequiredToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :profile_update_not_required, :boolean
  end
end
