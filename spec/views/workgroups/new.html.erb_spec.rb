require 'rails_helper'

RSpec.describe "workgroups/new", type: :view do
  before(:each) do
    assign(:workgroup, Workgroup.new())
  end

  it "renders new workgroup form" do
    render

    assert_select "form[action=?][method=?]", workgroups_path, "post" do
    end
  end
end