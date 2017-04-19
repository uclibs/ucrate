require 'rails_helper'

RSpec.describe WorkgroupMembership, type: :model do
  it 'has a valid factory' do
    expect(build(:workgroup_membership)).to be_valid
  end

  it 'is invalid without a user_id' do
    expect(build(:workgroup_membership, user_id: nil)).to be_invalid
  end

  it 'is invalid without a workgroup_id' do
    expect(build(:workgroup_membership, workgroup_id: nil)).to be_invalid
  end

  it 'is invalid without a role_id' do
    expect(build(:workgroup_membership, workgroup_id: nil)).to be_invalid
  end
end
