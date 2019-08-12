# frozen_string_literal: true

require 'rails_helper'

describe "Users API", clean_repo: true do
  let!(:user) { create(:user) }
  let(:user1) do
    {
      "email": "test@mail.com",
      "password": "password",
      "facebook_handle": "Facebook Handle",
      "twitter_handle": "Twitter Handle",
      "googleplus_handle": "Google+ Handle",
      "title": "Job title ",
      "website": "Personal webpage ",
      "telephone": "Campus phone number",
      "linkedin_handle": "fake_handle",
      "first_name": "First",
      "last_name": "Last",
      "alternate_phone_number": "Alternate phone number",
      "blog": "Blog",
      "alternate_email": "Alternate email",
      "ucdepartment": "UCL Development Team"
    }
  end
  describe "create user" do
    context "with valid JSON" do
      before do
        post '/api/users', params: user1, headers: { 'API-KEY' => 'testKey' }
      end

      it "responds with correct values" do
        new_user = User.find_by_email(user1[:email])
        expect(response.status).to eq(201)
        expect(new_user["email"]).to eq(user1[:email])
        expect(new_user["facebook_handle"]).to eq(user1[:facebook_handle])
        expect(new_user["twitter_handle"]).to eq(user1[:twitter_handle])
        expect(new_user["googleplus_handle"]).to eq(user1[:googleplus_handle])
        expect(new_user["title"]).to eq(user1[:title])
        expect(new_user["website"]).to eq(user1[:website])
        expect(new_user["telephone"]).to eq(user1[:telephone])
        expect(new_user["linkedin_handle"]).to eq(user1[:linkedin_handle])
        expect(new_user["first_name"]).to eq(user1[:first_name])
        expect(new_user["last_name"]).to eq(user1[:last_name])
        expect(new_user["alternate_phone_nuber"]).to eq(user1[:alternate_phone_nuber])
        expect(new_user["blog"]).to eq(user1[:blog])
        expect(new_user["alternate_email"]).to eq(user1[:alternate_email])
        expect(new_user["ucdepartment"]).to eq(user1[:ucdepartment])
      end
    end
  end

  describe "update user" do
    context "with valid JSON" do
      before do
        user1.delete(:password)
        user1.delete(:email)
        patch "/api/users/#{user[:email].gsub(/\./, '-dot-')}", params: user1, headers: { 'API-KEY' => 'testKey' }
      end

      it "responds with correct values" do
        new_user = User.find_by_email(user[:email])
        expect(response.status).to eq(200)
        expect(new_user["facebook_handle"]).to eq(user1[:facebook_handle])
        expect(new_user["twitter_handle"]).to eq(user1[:twitter_handle])
        expect(new_user["googleplus_handle"]).to eq(user1[:googleplus_handle])
        expect(new_user["title"]).to eq(user1[:title])
        expect(new_user["website"]).to eq(user1[:website])
        expect(new_user["telephone"]).to eq(user1[:telephone])
        expect(new_user["linkedin_handle"]).to eq(user1[:linkedin_handle])
        expect(new_user["first_name"]).to eq(user1[:first_name])
        expect(new_user["last_name"]).to eq(user1[:last_name])
        expect(new_user["alternate_phone_nuber"]).to eq(user1[:alternate_phone_nuber])
        expect(new_user["blog"]).to eq(user1[:blog])
        expect(new_user["alternate_email"]).to eq(user1[:alternate_email])
        expect(new_user["ucdepartment"]).to eq(user1[:ucdepartment])
      end
    end
  end

  describe "get user" do
    context "with valid JSON" do
      before do
        get "/api/users/#{user[:email].gsub(/\./, '-dot-')}", headers: { 'API-KEY' => 'testKey' }
      end

      it "returns correct response" do
        expect(response.status).to eq(200)
        expect(response.body).to eq(user.serializable_hash.to_json)
      end
    end
  end
end
