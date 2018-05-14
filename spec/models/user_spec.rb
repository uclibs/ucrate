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
  subject(:user) { described_class.new(email: 'test@example.com', password: 'test1234') }

  context 'when a user is not a student' do
    before do
      user.uc_affiliation = ''
    end
    it "returns false for .student?" do
      expect(user.student?).to be false
    end
  end

  context 'when a user is a student' do
    before do
      user.uc_affiliation = 'student'
    end
    it "returns true for .student?" do
      expect(user.student?).to be true
    end
  end

  it "sets waived_welcome_page to true" do
    user.save!
    user.waive_welcome_page!
    expect(user.waived_welcome_page).to be true
  end
end
