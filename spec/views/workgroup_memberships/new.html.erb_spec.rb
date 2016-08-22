require 'rails_helper'

RSpec.describe "workgroup_memberships/new.html.erb", type: :view do
  before(:each) do
    assign(:workgroup_membership, WorkgroupMembership.new({user_id: 1, workgroup_id: 1, workgroup_role_id: 1}))
  end

  it "renders the new workgroup membership form" do
    render
    assert_select "form[action=?][method=?]", workgroup_memberships_path, "post" do
    end
  end
end
