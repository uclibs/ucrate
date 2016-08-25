require 'rails_helper'

RSpec.describe "workgroups/index", type: :view do
  before(:each) do
    assign(:workgroups,
           [
             Workgroup.create!({ title: "My test title", description: "My description" }),
             Workgroup.create!({ title: "My title", description: "My description" })
           ])
  end

  it "renders a list of workgroups" do
    render
  end
end
