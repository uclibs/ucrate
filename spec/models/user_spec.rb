require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#name' do
    subject(:user) { described_class.new }

    context "when the user has a name" do
      before do
        user.first_name = "Lucy"
        user.last_name = "Bearcat"
      end

      it "return the user's name" do
        expect(user.name).to eq('Lucy Bearcat')
      end
    end

    context "when the user name is blank" do
      before do
        user.first_name = nil
        user.last_name = nil
        user.email = "lucy@mail.uc.edu"
      end

      it "return the user's email" do
        expect(user.name).to eq(user.email)
      end
    end
  end
end
