require 'rails_helper'

RSpec.describe "workgroup_memberships/edit.html.erb", type: :view do
  before(:each) do
    @user = FactoryGirl.create(:user)
    @workgroup = FactoryGirl.create(:workgroup)
    assign(:workgroup_membership, WorkgroupMembership.create({user_id: @user.id, workgroup_id: @workgroup.id, workgroup_role_id: 1}))
  end

  it "renders the edit workgroup role form" do
    render
  end
end
