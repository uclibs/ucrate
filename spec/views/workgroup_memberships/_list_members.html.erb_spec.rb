require 'rails_helper'

RSpec.describe "workgroup_memberships/_list_members.html.erb", type: :view do
  before(:each) do
    @user = FactoryGirl.create(:user)
    @user2 = FactoryGirl.create(:user2)
    @workgroup = FactoryGirl.create(:workgroup)
    @workgroup_role = FactoryGirl.create(:workgroup_role)
    assign(:workgroup_membership, WorkgroupMembership.create({user_id: @user.id, workgroup_id: @workgroup.id, workgroup_role_id: @workgroup_role.id}))
    assign(:workgroup_membership, WorkgroupMembership.create({user_id: @user2.id, workgroup_id: @workgroup.id, workgroup_role_id: @workgroup_role.id}))
  end

 it "renders a list of workgroup memberships" do
   render
 end
end
