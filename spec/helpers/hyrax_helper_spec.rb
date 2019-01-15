# frozen_string_literal: true

require 'rails_helper'

def new_state
  Blacklight::SearchState.new({}, CatalogController.blacklight_config)
end

RSpec.describe HyraxHelper, type: :helper do
  describe '#sorted_genre_list_for_documents' do
    it "returns an array" do
      expect(helper.sorted_genre_list_for_documents).to be_an(Array)
    end

    it "contains all the genre types for documents" do
      expect(helper.sorted_genre_list_for_documents).to eq(
        ['Book', 'Book Chapter', 'Brochure', 'Document', 'Letter', 'Manuscript', 'Newsletter', 'Pamphlet', 'Press Release', 'Report', 'White Paper']
      )
    end
  end

  describe '#sorted_genre_list_for_student_works' do
    it "returns an array" do
      expect(helper.sorted_genre_list_for_student_works).to be_an(Array)
    end

    it "contains all the genre types for student works" do
      expect(helper.sorted_genre_list_for_student_works).to eq(
        ['Book', 'Book Chapter', 'Brochure', 'Cartoon/Comic', 'Document', 'Letter', 'Manuscript', 'Map/Chart', 'Newsletter', 'Painting', 'Pamphlet', 'Photograph', 'Poster', 'Press Release', 'Report', 'Visual Art', 'White Paper']
      )
    end
  end

  describe '#sorted_genre_list_for_images' do
    it "returns an array" do
      expect(helper.sorted_genre_list_for_images).to be_an(Array)
    end

    it "contains all the genre types for student works" do
      expect(helper.sorted_genre_list_for_images).to eq(
        ['Cartoon/Comic', 'Map/Chart', 'Painting', 'Photograph', 'Poster', 'Visual Art']
      )
    end
  end

  describe "#sorted_college_list_for_works" do
    let(:etd) { Etd.new }
    let(:student_work) { StudentWork.new }
    let(:other_object) { GenericWork.new }

    it "returns the ETD list if the object is an ETD" do
      expect(helper.sorted_college_list_for_works(etd)).to eq(
        ["", "Allied Health Sciences", "Arts and Sciences", "Business", "College-Conservatory of Music", "Design, Architecture, Art and Planning", "Education, Criminal Justice, and Human Services", "Engineering and Applied Science", "Medicine", "Nursing", "Pharmacy", "Other", "Business Administration", "Education", "Engineering", "Interdisciplinary"]
      )
    end

    it "returns the Student Work list if the object is a Student Work" do
      expect(helper.sorted_college_list_for_works(student_work)).to eq(
        ["", "Allied Health Sciences", "Arts and Sciences", "Blue Ash College", "Business", "Clermont College", "College-Conservatory of Music", "Design, Architecture, Art and Planning", "Education, Criminal Justice, and Human Services", "Engineering and Applied Science", "Law", "Medicine", "Nursing", "Pharmacy", "Other"]
      )
    end

    it "returns the generic list for other classes" do
      expect(helper.sorted_college_list_for_works(other_object)).to eq(
        ["Allied Health Sciences", "Arts and Sciences", "Blue Ash College", "Business", "Clermont College", "College-Conservatory of Music", "Design, Architecture, Art and Planning", "Education, Criminal Justice, and Human Services", "Engineering and Applied Science", "Law", "Libraries", "Medicine", "Nursing", "Pharmacy", "Other"]
      )
    end
  end

  describe "#old_or_new_college" do
    let(:object_with_college_value) { instance_double('object', college: 'COB') }
    let(:object_with_no_college_value) { instance_double('object', college: '') }

    before do
      allow(helper).to receive(:current_user).and_return(
        instance_double('user', college: 'COM')
      )
    end

    it 'uses the preexisting college value if it already exists in the work' do
      expect(helper.old_or_new_college(object_with_college_value)).to eq('COB')
    end

    it 'fills in the college value from user profile if it does not already exist in a work.' do
      expect(helper.old_or_new_college(object_with_no_college_value)).to eq('COM')
    end
  end

  describe "#old_or_new_department" do
    let(:object_with_department_value) { instance_double('object', department: 'Chemistry') }
    let(:object_with_no_department_value) { instance_double('object', department: '') }

    before do
      allow(helper).to receive(:current_user).and_return(
        instance_double('user', department: 'Biology')
      )
    end

    it 'uses the preexisting department value if it already exists in the work' do
      expect(helper.old_or_new_department(object_with_department_value)).to eq('Chemistry')
    end

    it 'fills in the department value from user profile if it does not already exist in a work.' do
      expect(helper.old_or_new_department(object_with_no_department_value)).to eq('Biology')
    end
  end

  describe '#available_translations' do
    subject(:translation) { helper.available_translations }

    it do
      is_expected.to eq('en' => 'English',
                        'es' => 'Español',
                        'zh' => '中文')
    end
  end

  describe "#collection_title_by_id" do
    let(:solr_doc) { double(id: "abcd12345") }
    let(:bad_solr_doc) { double(id: "efgh67890") }
    let(:solr_response) { double(docs: [solr_doc]) }
    let(:bad_solr_response) { double(docs: [bad_solr_doc]) }
    let(:empty_solr_response) { double(docs: []) }
    let(:repository) { double }
    before do
      allow(controller).to receive(:repository).and_return(repository)
      allow(solr_doc).to receive(:[]).with("title_tesim").and_return(["Collection of Awesomeness"])
      allow(bad_solr_doc).to receive(:[]).with("title_tesim").and_return(nil)
      allow(repository).to receive(:find).with("abcd12345").and_return(solr_response)
      allow(repository).to receive(:find).with("efgh67890").and_return(bad_solr_response)
      allow(repository).to receive(:find).with("bad-id").and_return(empty_solr_response)
    end
    it "returns the first title of the collection" do
      expect(helper.collection_title_by_id("abcd12345")).to eq "Collection of Awesomeness"
    end
    it "returns nil if collection doesn't have title_tesim field" do
      expect(helper.collection_title_by_id("efgh67890")).to eq nil
    end
    it "returns nil if collection not found" do
      expect(helper.collection_title_by_id("bad-id")).to eq nil
    end
  end

  describe "#filtered_facet_field_names" do
    before do
      allow(helper).to receive(:facet_field_names).and_return(["college_sim", "department_sim", "other_sim"])
    end

    context "when no options are selected" do
      it "does not return department facet" do
        expect(helper.filtered_facet_field_names).to eq(["college_sim", "other_sim"])
      end
    end

    context "when college is selected" do
      before do
        allow(helper).to receive(:params).and_return("f" => { "college_sim" => true })
      end

      it "returns department facet" do
        expect(helper.filtered_facet_field_names).to eq(["college_sim", "department_sim", "other_sim"])
      end
    end

    context "when facet other than college is selected" do
      before do
        allow(helper).to receive(:params).and_return("f" => { "other_sim" => true })
      end

      it "does not return department facet" do
        expect(helper.filtered_facet_field_names).to eq(["college_sim", "other_sim"])
      end
    end
  end
end
