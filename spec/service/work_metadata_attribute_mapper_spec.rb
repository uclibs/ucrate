require 'rails_helper'

RSpec.describe WorkMetadataAttributeMapper do
  let(:work) do
    create(:work,
           title: ["A very short work"],
           creator: ["Foo Bar"],
           subject: ["This subject"],
           description: ["Much shorter than most works"])
  end

  subject(:mapper) { described_class.new(work) }

  it "instantiates the #{described_class}" do
    expect(mapper).to be_an_instance_of(described_class)
  end

  describe "#object_attributes" do
    let(:export_configuration) do
      {
        "GenericWork" => ["id", "depositor", "title", "creator", "description"],
        "Collection" => ["id", "depositor", "title", "creator"]
      }
    end

    before do
      allow(YAML).to receive(:load_file).and_return(export_configuration)
    end

    it "returns a hash" do
      expect(mapper.object_attributes.class).to eq(Hash)
    end

    it "includes all the attributes specified in the configuration" do
      expect(mapper.object_attributes.keys).to eq(["id", "depositor", "title", "creator", "description"])
    end

    it "includes the values for specified attributes" do
      expect(mapper.object_attributes.values).to include(work.id, work.depositor, work.title, work.creator, work.description)
    end

    it "doesn't include the values for unspecified attributes" do
      expect(mapper.object_attributes.values).not_to include(work.subject)
    end
  end
end
