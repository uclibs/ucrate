require 'rails_helper'

RSpec.describe WorkgroupRole, type: :model do
  it 'has a valid factory' do
    expect(build(:workgroup_role)).to be_valid
  end

  it 'is invalid without a name' do
    expect(build(:workgroup_role, name: nil)).to be_invalid
  end
end
