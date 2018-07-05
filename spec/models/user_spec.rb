# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe "#name_for_people_page" do
    subject(:user) { described_class.new }

    context "with first_name and last_name set" do
      before do
        user.first_name = "Lucy"
        user.last_name = "Bearcat"
      end

      it "returns the name" do
        expect(user.name_for_people_page).to eq("Bearcat, Lucy")
      end
    end

    context "with first_name blank and last_name set" do
      before do
        user.last_name = "Bearcat"
      end

      it "returns the name" do
        expect(user.name_for_people_page).to eq('')
      end
    end

    context "with first_name set and last_name blank" do
      before do
        user.first_name = "Lucy"
      end

      it "returns the name" do
        expect(user.name_for_people_page).to eq('')
      end
    end

    context "with first_name and last_name blank set" do
      it "returns the name" do
        expect(user.name_for_people_page).to eq('')
      end
    end
  end

  describe "#name_for_works" do
    subject(:user) { described_class.new }

    context "with first_name and last_name set" do
      before do
        user.first_name = "Lucy"
        user.last_name = "Bearcat"
      end

      it "returns the name" do
        expect(user.name_for_works).to eq("Bearcat, Lucy")
      end
    end

    context "with first_name blank and last_name set" do
      before do
        user.last_name = "Bearcat"
      end

      it "returns the name" do
        expect(user.name_for_works).to eq(nil)
      end
    end

    context "with first_name set and last_name blank" do
      before do
        user.first_name = "Lucy"
      end

      it "returns the name" do
        expect(user.name_for_works).to eq(nil)
      end
    end

    context "with first_name and last_name blank set" do
      it "returns the name" do
        expect(user.name_for_works).to eq(nil)
      end
    end
  end

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
