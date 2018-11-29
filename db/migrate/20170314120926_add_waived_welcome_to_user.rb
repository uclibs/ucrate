class AddWaivedWelcomeToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :waived_welcome_page, :boolean
  end
end
