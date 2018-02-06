require 'rails_helper'

RSpec.describe Ability, type: :model do
  it 'responds to :custom_permissions' do
    expect(described_class.method_defined?(:custom_permissions)).to be true
  end
end
