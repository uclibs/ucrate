class AddWorkgroupRoleIdToWorkgroupMembership < ActiveRecord::Migration
  def change
    add_column :workgroup_memberships, :workgroup_role_id, :integer
  end
end
