class CreateWorkgroupMemberships < ActiveRecord::Migration
  def change
    create_table :workgroup_memberships do |t|

      t.timestamps null: false
    end
  end
end
