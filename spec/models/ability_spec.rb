# frozen_string_literal: true

require 'rails_helper'
require 'cancan/matchers'

RSpec.describe Ability, type: :model do
  it 'responds to :custom_permissions' do
    expect(described_class.method_defined?(:custom_permissions)).to be true
  end

  describe "a user in the ETD manager group" do
    let(:ability) { described_class.new(user) }
    subject { ability }
    let(:user) { create(:user) }
    before { allow(user).to receive_messages(groups: ['etd_manager', 'registered']) }
    it { is_expected.to be_able_to(:create, Etd) }
    it { is_expected.to be_able_to(:edit, Etd) }
    it { is_expected.to be_able_to(:delete, Etd) }
    it { is_expected.to be_able_to(:read, Etd) }
    it { is_expected.to be_able_to(:manage, Etd) }
  end
end
