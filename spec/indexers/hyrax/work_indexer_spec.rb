# frozen_string_literal: true
require 'rails_helper'

describe Hyrax::WorkIndexer do
  let(:indexer) { described_class.new(work) }
  let(:work1title) { 'work1 title' }
  let(:work2title) { 'work2 title' }

  describe "#generate_solr_document" do
    let(:work) { FactoryBot.build(:generic_work) }
    subject(:document) { indexer.generate_solr_document }

    it "makes date_created facetable" do
      work.stub(:date_created).and_return("1950-01-01")
      expect(work.to_solr["date_created_tesim"]).to eq(["1950-01-01"])
    end

    it "removes leading spaces" do
      work.stub(:title).and_return(["  I start with a space"])
      expect(work.to_solr["sort_title_ssi"]).to eq("I START WITH A SPACE")
    end

    it "removes leading articles" do
      work.stub(:title).and_return(["The the is first"])
      expect(work.to_solr["sort_title_ssi"]).to eq("THE IS FIRST")
    end

    it "removes non alphanumeric characters" do
      work.stub(:title).and_return(["Title* 30! Sure& $has$ a &lot& of ^^^punctuation!!!!"])
      expect(work.to_solr["sort_title_ssi"]).to eq("TITLE 30 SURE HAS A LOT OF PUNCTUATION")
    end

    it "removes double spaces" do
      work.stub(:title).and_return(["This  title has      extra   spaces"])
      expect(work.to_solr["sort_title_ssi"]).to eq("THIS TITLE HAS EXTRA SPACES")
    end

    it "upcases everything" do
      work.stub(:title).and_return(["i should be uppercase"])
      expect(work.to_solr["sort_title_ssi"]).to eq("I SHOULD BE UPPERCASE")
    end

    it "adds leading 0s as needed" do
      work.stub(:title).and_return(["1) Is the first title"])
      expect(work.to_solr["sort_title_ssi"]).to eq("00000000000000000001 IS THE FIRST TITLE")
    end
  end
end
