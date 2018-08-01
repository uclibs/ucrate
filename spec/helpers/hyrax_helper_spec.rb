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
end
