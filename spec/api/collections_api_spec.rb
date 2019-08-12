# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Collections API", clean_repo: true do
  let!(:user) { create(:user) }
  let(:generatedCollection) { create(:public_collection, user: user) }
  let(:collection1) do
    {
      "title": "Collection 1",
      "email": "test@mail.com",
      "first_name": "Test",
      "last_name": "Last",
      "creator": "Me",
      "description": "test",
      "license": "http://rightsstatements.org/vocab/InC/1.0/",
      "access": "open"
    }
  end

  let(:updateCollection) do
    {
      "title": "Update",
      "creator": "Update",
      "description": "Update",
      "license": "http://creativecommons.org/licenses/by/4.0/",
      "access": "restricted"
    }
  end

  describe "create collection" do
    context "with new user" do
      before do
        post '/api/collections', params: collection1, headers: { 'API-KEY' => 'testKey' }
      end

      it "responds with correct values" do
        # These must be in the it block
        hash = JSON.parse response.body
        collection = Collection.find(hash['id'])
        expect(User.count).to eq(2)
        expect(response.status).to eq(201)
        expect(collection.title).to eq([collection1[:title]])
        expect(collection.depositor).to eq(collection1[:email])
        expect(collection.creator).to eq([collection1[:creator]])
        expect(collection.description).to eq([collection1[:description]])
        expect(collection.license).to eq(collection1[:license])
        expect(collection.visibility).to eq(collection1[:access])
      end
    end

    context "with existing user" do
      before do
        collection1[:email] = user.email
        post '/api/collections', params: collection1, headers: { 'API-KEY' => 'testKey' }
      end

      it "responds with correct values" do
        # These must be in the it block
        hash = JSON.parse response.body
        collection = Collection.find(hash['id'])
        expect(User.count).to eq(1)
        expect(response.status).to eq(201)
        expect(collection.title).to eq([collection1[:title]])
        expect(collection.depositor).to eq(collection1[:email])
        expect(collection.creator).to eq([collection1[:creator]])
        expect(collection.description).to eq([collection1[:description]])
        expect(collection.license).to eq(collection1[:license])
        expect(collection.visibility).to eq(collection1[:access])
      end
    end

    context "with invalid JSON" do
      before do
        collection1.delete :access
        post '/api/collections', params: collection1, headers: { 'API-KEY' => 'testKey' }
      end

      it "responds with the correct error message" do
        expect(response.status).to eq(400)
        expect(response.body).to eq("{\"error\":\"access is missing\"}")
      end
    end
  end

  describe "update collection" do
    context "with valid JSON" do
      before do
        collection = Collection.find(generatedCollection.id)
        patch "/api/collections/#{collection.id}", params: updateCollection, headers: { 'API-KEY' => 'testKey' }
      end

      it "returns correct response" do
        expect(response.status).to eq(200)
        hash = JSON.parse response.body
        expect(hash["title"]).to include(updateCollection[:title])
        expect(hash["creator"]).to include(updateCollection[:creator])
        expect(hash["description"]).to include(updateCollection[:description])
        expect(hash["license"]).to include(updateCollection[:license])
        expect(Collection.find(hash["id"]).visibility).to include(updateCollection[:access])
        expect(hash["date_modified"]).not_to be_nil
      end
    end
  end

  describe "get collection" do
    context "with valid JSON" do
      before do
        collection = Collection.find(generatedCollection.id)
        get "/api/collections/#{collection.id}", headers: { 'API-KEY' => 'testKey' }
      end

      it "returns correct response" do
        expect(response.status).to eq(200)
        expect(response.body).to eq(generatedCollection.to_json)
      end
    end
  end
end
