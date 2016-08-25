require 'rails_helper'

RSpec.describe "workgroups/show", type: :view do
  before(:each) do
    @workgroup = assign(:workgroup, Workgroup.create!({ title: "My title", description: "My description" }))
  end

  it "renders attributes in <p>" do
    render
  end
end
