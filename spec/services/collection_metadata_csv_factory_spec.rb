require 'rails_helper'

RSpec.describe CollectionMetadataCsvFactory do
  let(:user) { create(:user, email: "test_email@example.com") }

  let(:collection) do
    create(:public_collection,
           user: user,
           description: ['collection description'],
           collection_type_settings: :nestable)
  end

  let!(:nested_collection) do
    create(:public_collection,
           id: "1",
           member_of_collections: [collection],
           user: user,
           title: ["Collection title"],
           creator: ["Collection creator"],
           description: ['collection description'],
           collection_type_settings: :nestable)
  end

  let!(:work1) do
    create(:work,
           id: "2",
           title: ["King Louie"],
           creator: ["Test Creator"],
           description: ["This is a description"],
           member_of_collections: [collection],
           user: user)
  end

  let!(:work2) do
    create(:work,
           id: "3",
           title: ["King Kong"],
           creator: ["Test Creator 2"],
           description: ["This is a description"],
           member_of_collections: [collection],
           user: user)
  end

  subject(:csv_factory) { described_class.new(collection.id) }

  it "instantiates the #{described_class}" do
    expect(csv_factory).to be_an_instance_of(described_class)
  end

  describe "#create_csv" do
    before do
      allow(Time).to receive(:now).and_return(Time.new(2018))
      allow(YAML).to receive(:load_file).and_return(export_configuration)
    end

    let(:expected_location) do
      Rails.root.join('tmp', "#{collection.id}.#{Time.new(2018).to_i}.csv")
    end

    let(:export_configuration) do
      {
        "GenericWork" => ["id", "depositor", "description", "title", "creator"],
        "Collection" => ["id", "depositor", "title", "creator"]
      }
    end

    let(:expected_csv) do
      File.open(Rails.root.join('spec', 'fixtures', 'export.csv'))
    end

    it "creates the csv" do
      expect(File.open(csv_factory.create_csv).read).to eq(expected_csv.read)
    end

    it "returns the location of the csv" do
      expect(csv_factory.create_csv).to eq(expected_location)
    end
  end
end
