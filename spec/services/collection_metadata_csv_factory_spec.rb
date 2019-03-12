# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionMetadataCsvFactory do
  subject(:csv_factory) { described_class.new(collection.id) }
  let(:user) { create(:user, email: "test_email@example.com") }

  let!(:collection) do
    create(:public_collection,
           id: 1,
           title: ["Parent Collection"],
           user: user,
           description: ['collection description'],
           collection_type_settings: :nestable)
  end

  let!(:article) do
    create(:article,
           id: 2,
           title: ["Article"],
           creator: ["Putnam, Robert"],
           description: ["Bowling Alone Article"],
           college: "Arts and Letters Article",
           department: "Social Science",
           license: ["All Rights Reserved"],
           publisher: ["Macmillan Reference"],
           date_created: ["2000-01-01"],
           alternate_title: ["Bowling Alone: The decline of American Social Capital"],
           journal_title: ["American Governance"],
           issn: ["978-0-02-866249-7"],
           subject: ["United States Politics"],
           geo_subject: ["United States"],
           time_period: ["Early Aughts"],
           language: ["English"],
           required_software: "PDF",
           note: "Article Note",
           related_url: ["www.example.com/article"],
           member_of_collections: [collection],
           doi: "00001",
           user: user)
  end

  let!(:dataset) do
    create(:dataset,
           id: 3,
           title: ["Dataset"],
           creator: ["Putnam, Robert"],
           description: ["Bowling Alone"],
           college: "Arts and Letters",
           department: "Social Science",
           license: ["All Rights Reserved"],
           publisher: ["Macmillan Reference"],
           date_created: ["2000-01-01"],
           alternate_title: ["Bowling Alone: The decline of American Social Capital"],
           subject: ["United States Politics"],
           geo_subject: ["United States"],
           time_period: ["Early Aughts"],
           language: ["English"],
           required_software: "PDF",
           note: "Dataset Note",
           related_url: ["www.example.com/dataset"],
           member_of_collections: [collection],
           doi: "00002",
           user: user)
  end

  let!(:document) do
    create(:document,
           id: 4,
           title: ["Document"],
           creator: ["Putnam, Robert"],
           description: ["Bowling Alone"],
           college: "Arts and Letters",
           department: "Social Science",
           license: ["All Rights Reserved"],
           publisher: ["Macmillan Reference"],
           date_created: ["2000-01-01"],
           alternate_title: ["Bowling Alone: The decline of American Social Capital"],
           subject: ["United States Politics"],
           geo_subject: ["United States"],
           time_period: ["Early Aughts"],
           language: ["English"],
           required_software: "PDF",
           note: "Document Note",
           related_url: ["www.example.com/document"],
           member_of_collections: [collection],
           genre: "Non Fiction",
           doi: "00003",
           user: user)
  end

  let!(:etd) do
    create(:etd,
           id: 5,
           title: ["Etd"],
           creator: ["Putnam, Robert"],
           description: ["Bowling Alone"],
           college: "Arts and Letters",
           department: "Social Science",
           advisor: ["Mulaney, John"],
           committee_member: ["Kroll, Nick"],
           degree: "Political Science",
           license: ["All Rights Reserved"],
           etd_publisher: "Macmillan Reference",
           date_created: ["2000-01-01"],
           alternate_title: ["Bowling Alone: The decline of American Social Capital"],
           subject: ["United States Politics"],
           geo_subject: ["United States"],
           time_period: ["Early Aughts"],
           language: ["English"],
           required_software: "PDF",
           note: "Etd Note",
           related_url: ["www.example.com/etd"],
           member_of_collections: [collection],
           genre: "Non Fiction",
           doi: "00004",
           user: user)
  end

  let!(:work) do
    create(:work,
           id: 6,
           title: ["Work"],
           creator: ["Putnam, Robert"],
           description: ["Bowling Alone"],
           college: "Arts and Letters",
           department: "Social Science",
           license: ["All Rights Reserved"],
           publisher: ["Macmillan Reference"],
           date_created: ["2000-01-01"],
           alternate_title: ["Bowling Alone: The decline of American Social Capital"],
           subject: ["United States Politics"],
           geo_subject: ["United States"],
           time_period: ["Early Aughts"],
           language: ["English"],
           required_software: "PDF",
           note: "Work Note",
           related_url: ["www.example.com/work"],
           member_of_collections: [collection],
           doi: "00005",
           user: user)
  end

  let!(:image) do
    create(:image,
           id: 7,
           title: ["Image"],
           creator: ["Putnam, Robert"],
           description: ["Bowling Alone"],
           college: "Arts and Letters",
           department: "Social Science",
           license: ["All Rights Reserved"],
           publisher: ["Macmillan Reference"],
           date_created: ["2000-01-01"],
           alternate_title: ["Bowling Alone: The decline of American Social Capital"],
           subject: ["United States Politics"],
           geo_subject: ["United States"],
           time_period: ["Early Aughts"],
           language: ["English"],
           required_software: "PDF",
           note: "Image Note",
           related_url: ["www.example.com/image"],
           member_of_collections: [collection],
           doi: "00006",
           user: user)
  end

  let!(:medium) do
    create(:medium,
           id: 8,
           title: ["Medium"],
           creator: ["Putnam, Robert"],
           description: ["Bowling Alone"],
           college: "Arts and Letters",
           department: "Social Science",
           license: ["All Rights Reserved"],
           publisher: ["Macmillan Reference"],
           date_created: ["2000-01-01"],
           alternate_title: ["Bowling Alone: The decline of American Social Capital"],
           subject: ["United States Politics"],
           geo_subject: ["United States"],
           time_period: ["Early Aughts"],
           language: ["English"],
           required_software: "PDF",
           note: "Medium Note",
           related_url: ["www.example.com/medium"],
           member_of_collections: [collection],
           doi: "00007",
           user: user)
  end

  let!(:student_work) do
    create(:student_work,
           id: 9,
           title: ["Student Work"],
           creator: ["Putnam, Robert"],
           description: ["Bowling Alone"],
           college: "Arts and Letters",
           department: "Social Science",
           advisor: ["Kroll, Nick"],
           license: ["All Rights Reserved"],
           degree: "Political Science",
           publisher: ["Macmillan Reference"],
           date_created: ["2000-01-01"],
           alternate_title: ["Bowling Alone: The decline of American Social Capital"],
           genre: "Non Fiction",
           subject: ["United States Politics"],
           geo_subject: ["United States"],
           time_period: ["Early Aughts"],
           language: ["English"],
           required_software: "PDF",
           note: "Student Work Note",
           related_url: ["www.example.com/student_work"],
           member_of_collections: [collection],
           doi: "00008",
           user: user)
  end

  let!(:nested_collection) do
    create(:public_collection,
           id: "10",
           member_of_collections: [collection],
           user: user,
           title: ["Nested Collection title"],
           creator: ["Nested Collection creator"],
           description: ['nested collection description'],
           collection_type_settings: :nestable)
  end

  let!(:nested_document) do
    create(:document,
           id: 11,
           title: ["Nested Document"],
           creator: ["Putnam, Robert"],
           description: ["Bowling Alone"],
           college: "Arts and Letters",
           department: "Social Science",
           license: ["All Rights Reserved"],
           publisher: ["Macmillan Reference"],
           date_created: ["2000-01-01"],
           alternate_title: ["Bowling Alone: The decline of American Social Capital"],
           subject: ["United States Politics"],
           geo_subject: ["United States"],
           time_period: ["Early Aughts"],
           language: ["English"],
           required_software: "PDF",
           note: "Document Note",
           related_url: ["www.example.com/document"],
           member_of_collections: [nested_collection],
           genre: "Non Fiction",
           doi: "00009",
           user: user)
  end

  it "instantiates the #{described_class}" do
    expect(csv_factory).to be_an_instance_of(described_class)
  end

  describe "#create_csv" do
    before do
      allow(Time).to receive(:now).and_return(Time.new(2018))
      allow(YAML).to receive(:load_file).and_return(export_configuration)

      article.ordered_members << create(:file_set, id: 12, user: user, title: ['A Contained FileSet'], label: 'filename.pdf')
    end

    let(:expected_location) do
      Rails.root.join('tmp', "#{collection.id}.#{Time.new(2018).to_i}.csv")
    end

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
        "Collection" => ["id", "depositor", "title", "creator"]
      }
    end

    let(:expected_csv) do
      File.open(Rails.root.join('spec', 'fixtures', 'export.csv'))
    end

    csv_variables = {}
    it "creates the csv" do
      article.file_sets.each_with_index do |file_set, i|
        csv_variables[:"id_#{i}"] = file_set.id
        csv_variables[:"email_#{i}"] = file_set.depositor
      end
      expect(File.open(csv_factory.create_csv).read).to eq(expected_csv.read)
    end

    it "returns the location of the csv" do
      expect(csv_factory.create_csv).to eq(expected_location)
    end
  end
end
