require 'rails_helper'

RSpec.describe Workgroup, type: :model do 
  it 'has a valid factory' do
    expect(create(:workgroup)).to be_valid
  end
end
