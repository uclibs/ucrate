require 'rails_helper'

RSpec.describe Workgroup, type: :model do 
  it 'has a valid factory' do
    expect(build(:workgroup)).to be_valid
  end
  it 'is invalid without a title' do
  	expect(build(:workgroup, title: nil)).to be_invalid
  end

  it 'is invalid without a description' do
  	expect(build(:workgroup, description: nil)).to be_invalid
  end
end
