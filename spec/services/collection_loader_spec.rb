# frozen_string_literal: true
require "rails_helper"

describe CollectionLoader, :clean_repo do
  let(:user) { create(:user) }
  let(:collection_pid) { nil }
  let(:collection_type) { create(:collection_type, id: 1) }
  let(:attributes) do
    {
      pid:                 collection_pid,
      submitter_email:     user.email,
      title:               ["A Large Collection"],
      description:         "My description",
      creator:             ["Ono, Santa"],
      license:             "http://creativecommons.org/licenses/by-nc/4.0/",
      visibility:          "open",
      collection_type_gid: collection_type.gid
    }
  end

  subject(:collection_loader) { described_class.new(attributes) }

  it "instantiates the #{described_class}" do
    expect(collection_loader).to be_an_instance_of(described_class)
  end

  it "instantiates the collection with attributes" do # rubocop:disable RSpec/ExampleLength
    expect(collection_loader.collection).to be_an_instance_of(Collection)

    expect(collection_loader.collection.title).to       eq(attributes[:title])
    expect(collection_loader.collection.description).to eq([attributes[:description]])
    expect(collection_loader.collection.creator).to     eq(attributes[:creator])
    expect(collection_loader.collection.license).to     eq(attributes[:license])
    expect(collection_loader.collection.visibility).to  eq(attributes[:visibility])
    expect(collection_loader.collection.depositor).to   eq(attributes[:submitter_email])
    expect(collection_loader.collection.collection_type_gid).to eq(attributes[:collection_type_gid])
  end

  describe "#create" do
    before { collection_loader.create }
    it "saves the collection" do
      expect(collection_loader.collection.id).not_to be_nil
    end

    context "when an id is specified" do
      let(:collection_pid) { "foo1234" }
      it "saves the collection with that id" do
        expect(collection_loader.collection.id).to eq(collection_pid)
      end
    end
  end
end
