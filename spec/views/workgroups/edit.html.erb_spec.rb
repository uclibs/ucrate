require 'rails_helper'

RSpec.describe "workgroups/edit", type: :view do
  before(:each) do
    @workgroup = assign(:workgroup, Workgroup.create!())
  end

  it "renders the edit workgroup form" do
    render

    assert_select "form[action=?][method=?]", workgroup_path(@workgroup), "post" do
    end
  end
end
