class AddColumnToWorkgroupMembership < ActiveRecord::Migration
  def change
    add_column :workgroup_memberships, :user_id, :integer
    add_column :workgroup_memberships, :workgroup_id, :integer
  end
end
