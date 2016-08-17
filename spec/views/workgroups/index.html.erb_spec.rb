require 'rails_helper'

RSpec.describe "workgroups/index", type: :view do
  before(:each) do
    assign(:workgroups, [
      Workgroup.create!(),
      Workgroup.create!()
    ])
  end

  it "renders a list of workgroups" do
    render
  end
end
