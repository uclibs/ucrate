require 'rails_helper'

RSpec.describe "workgroups/edit", type: :view do
  let!(:workgroup) { assign(:workgroup, Workgroup.create!({ title: "My title", description: "My description" })) }

  it "renders the edit workgroup form" do
    render

    assert_select "form[action=?][method=?]", workgroup_path(workgroup), "post" do
    end
  end
end
