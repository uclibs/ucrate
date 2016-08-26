require 'rails_helper'

RSpec.describe User, type: :model do 
  it 'has a valid factory' do
    expect(build(:user)).to be_valid
  end
  it 'is valid without a first name' do
    expect(build(:user, first_name: nil)).to be_valid
  end
  it 'is valid without a last name' do
    expect(build(:user, last_name: nil)).to be_valid
  end
end
