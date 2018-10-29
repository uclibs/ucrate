# frozen_string_literal: true
require 'rails_helper'

describe Hyrax::CollectionIndexer do
  let(:indexer) { described_class.new(collection) }
  let(:collection) { build(:collection) }
  let(:col1id) { 'col1' }
  let(:col2id) { 'col2' }
  let(:col1title) { 'col1 title' }
  let(:col2title) { 'col2 title' }
  let(:col1) { instance_double(Collection, id: col1id, to_s: col1title) }
  let(:col2) { instance_double(Collection, id: col1id, to_s: col2title) }

  describe "#generate_solr_document" do
    before do
      allow(collection).to receive(:bytes).and_return(1000)
      allow(collection).to receive(:in_collections).and_return([col1, col2])
      allow(col1).to receive(:id).and_return(col1id)
      allow(col2).to receive(:id).and_return(col2id)
      allow(col1).to receive(:first_title).and_return(col1title)
      allow(col2).to receive(:first_title).and_return(col2title)

      allow(Hyrax::ThumbnailPathService).to receive(:call).and_return("/downloads/1234?file=thumbnail")
    end

    subject { indexer.generate_solr_document }

    it "has required fields" do
      expect(subject.fetch('generic_type_sim')).to eq ["Collection"]
      expect(subject.fetch('bytes_lts')).to eq(1000)
      expect(subject.fetch('thumbnail_path_ss')).to eq "/downloads/1234?file=thumbnail"
      expect(subject.fetch('member_of_collection_ids_ssim')).to eq [col1id, col2id]
      expect(subject.fetch('member_of_collections_ssim')).to eq [col1title, col2title]
    end

    it "removes leading spaces" do
      collection.stub(:title).and_return ["  I start with a space"]
      expect(subject.fetch('sort_title_ssi')).to eq("I START WITH A SPACE")
    end

    it "removes leading articles" do
      collection.stub(:title).and_return(["The the is first"])
      expect(subject.fetch('sort_title_ssi')).to eq("THE IS FIRST")
    end

    it "removes non alphanumeric characters" do
      collection.stub(:title).and_return(["Title* 30! Sure& $has$ a &lot& of ^^^punctuation!!!!"])
      expect(subject.fetch('sort_title_ssi')).to eq("TITLE 30 SURE HAS A LOT OF PUNCTUATION")
    end

    it "removes double spaces" do
      collection.stub(:title).and_return(["This  title has      extra   spaces"])
      expect(subject.fetch('sort_title_ssi')).to eq("THIS TITLE HAS EXTRA SPACES")
    end

    it "upcases everything" do
      collection.stub(:title).and_return(["i should be uppercase"])
      expect(subject.fetch('sort_title_ssi')).to eq("I SHOULD BE UPPERCASE")
    end

    it "adds leading 0s as needed" do
      collection.stub(:title).and_return(["1) Is the first title"])
      expect(subject.fetch('sort_title_ssi')).to eq("00000000000000000001 IS THE FIRST TITLE")
    end
  end
end
