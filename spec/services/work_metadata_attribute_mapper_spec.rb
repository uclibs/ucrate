# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkMetadataAttributeMapper do
  subject(:mapper) { described_class.new(work, nil) }
  let(:work) do
    create(:work,
           title: ["A very short work"],
           creator: ["Foo Bar"],
           subject: ["This subject"],
           description: ["Much shorter than most works"])
  end

  it "instantiates the #{described_class}" do
    expect(mapper).to be_an_instance_of(described_class)
  end

  describe "#object_attributes" do
    let(:export_configuration) do
      {
        "GenericWork" => ["id", "title", "creator", "depositor", "description", "college", "department", "license", "publisher", "date_created", "alternate_title", "subject", "geo_subject", "time_period", "language", "required_software", "note", "related_url"],
        "Article" => ["id", "title", "creator", "depositor", "description", "college", "department", "license", "publisher", "date_created", "alternate_title", "journal_title", "issn", "subject", "geo_subject", "time_period", "language", "required_software", "note", "related_url"],
        "Document" => ["id", "title", "creator", "depositor", "description", "college", "department", "license", "publisher", "date_created", "alternate_title", "genre", "subject", "geo_subject", "time_period", "language", "required_software", "related_url"],
        "Dataset" => ["id", "title", "creator", "depositor", "description", "college", "department", "required_software", "license", "publisher", "date_created", "alternate_title", "subject", "geo_subject", "time_period", "language", "note", "related_url"],
        "Image" => ["id", "title", "creator", "depositor", "description", "college", "department", "license", "publisher", "date_created", "alternate_title", "genre", "subject", "geo_subject", "time_period", "language", "required_software", "note", "related_url"],
        "Medium" => ["id", "title", "creator", "depositor", "description", "college", "department", "license", "publisher", "date_created", "alternate_title", "genre", "subject", "geo_subject", "time_period", "language", "required_software", "note", "related_url"],
        "Etd" => ["id", "title", "creator", "depositor", "description", "college", "department", "advisor", "license", "committee_member", "degree", "etd_publisher", "date_created", "alternate_title", "genre", "subject", "geo_subject", "time_period", "language", "required_software", "note", "related_url"],
        "StudentWork" => ["id", "title", "creator", "depositor", "description", "college", "department", "advisor", "license", "degree", "publisher", "date_created", "alternate_title", "genre", "subject", "geo_subject", "time_period", "language", "required_software", "note", "related_url"],
        "Collection" => ["id", "title", "creator", "depositor"]
      }
    end

    before do
      allow(YAML).to receive(:load_file).and_return(export_configuration)
    end

    it "returns a hash" do
      expect(mapper.object_attributes.class).to eq(Hash)
    end

    it "includes all the attributes specified in the configuration" do
      expect(mapper.object_attributes.keys).to eq(["id", "title", "creator", "depositor", "description", "college", "department", "license", "publisher", "date_created", "alternate_title", "subject", "geo_subject", "time_period", "language", "required_software", "note", "related_url"])
    end

    it "includes the values for specified attributes" do
      expect(mapper.object_attributes.values).to include(work.id, work.depositor, work.title, work.creator, work.description)
    end
  end
end
