# frozen_string_literal: true
require "rails_helper"

describe WorkLoader, :clean_repo do
  let(:user) { create(:user) }
  let!(:role1) { Sipity::Role.create(name: 'depositing') }
  let(:work_pid) { nil }
  let(:file_pid1) { nil }
  let(:file_pid2) { nil }
  let(:collection_ids) { [] }
  let(:member_work_ids) { nil }
  let(:editors) { nil }
  let(:readers) { nil }
  let!(:admin_set_id) { AdminSet.find_or_create_default_admin_set_id }
  let!(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_id) }
  let!(:workflow) { Sipity::Workflow.create!(active: true, name: 'test-workflow', permission_template: permission_template) }

  before do
    allow(CharacterizeJob).to receive(:perform_later)

    # Create a single action that can be taken
    Sipity::WorkflowAction.create!(name: 'submit', workflow: workflow)

    # Grant the user access to deposit into the admin set.
    Hyrax::PermissionTemplateAccess.create!(
      permission_template_id: permission_template.id,
      agent_type: 'user',
      agent_id: user.user_key,
      access: 'deposit'
    )
  end
  let(:files) do
    [
      {
        path:         "#{fixture_path}/world.png",
        title:        "World!",
        visibility:   "restricted",
        embargo_date: "",
        uri:          "",
        pid:          file_pid1
      },
      {
        path:         "#{fixture_path}/test_file.txt",
        title:        "Test file",
        visibility:   "open",
        embargo_date: "",
        uri:          "",
        pid:          file_pid2
      }
    ]
  end

  let(:default_attributes) do
    {
      pid:                      work_pid,
      work_type:                "generic_work",
      submitter_email:          user.email,
      files:                    files,
      title:                    ["My title"],
      creator:                  ["Creator"],
      description:              ["My description"],
      college:                  "Libraries",
      department:               "Digital Collections",
      license:                  ["http://creativecommons.org/licenses/by-nc/4.0/"],
      rights_statement:         ["These are your rights, all three of them"],
      geo_subject:              ["Dayton, Ohio"],
      visibility:               "open",
      edit_access:              editors,
      read_access:              readers,
      member_of_collection_ids: collection_ids,
      member_work_ids:          member_work_ids
    }
  end

  shared_examples_for "batch upload object" do
    subject(:work_loader) { described_class.new(attributes) }

    it "instantiates the class with minimal required attributes" do
      expect(work_loader).to be_an_instance_of(described_class)
    end

    it "instantiates a new curation_concern" do
      expect(work_loader.curation_concern).to be_an_instance_of(work_type.constantize)
    end

    it "builds an actor" do
      expect(work_loader.ability).to be_an_instance_of(Ability)
    end

    it "creates uploaded files" do
      expect(work_loader.file_attributes).to be_an_instance_of(Array)
      expect(work_loader.file_attributes.length).to be(2)
      expect(work_loader.file_attributes.first[:uploaded_file]).to be_an_instance_of(Hyrax::UploadedFile)
    end

    describe "#create" do
      before { work_loader.create }
      it "saves the curation concern" do
        expect(work_loader.curation_concern.id).not_to be_nil
      end

      it "includes specified attributes" do
        expect(work_loader.curation_concern).to have_attributes(attributes)
      end

      it "attaches the files" do
        expect(work_loader.curation_concern.file_sets.length).to be(2)
        expect(work_loader.curation_concern.file_sets.map(&:id)).not_to include(nil)
      end

      context "when collection membership is specified" do
        let!(:collection) { create(:collection) }
        let(:collection_ids) { [collection.id] }

        it "adds the curation concern to the collection" do
          expect(work_loader.curation_concern.member_of_collections.first.id).to eq collection.id
        end
      end

      context "when file pid is specified" do
        let(:file_pid2) { "bez2345" }
        it "saves with the specified pid " do
          expect(work_loader.curation_concern.file_sets.map(&:id)).to include(file_pid2)
        end
      end

      context "when work pid is specified" do
        let(:work_pid) { "foo1234" }
        it "saves with the specified pid " do
          expect(work_loader.curation_concern.id).to eq(work_pid)
        end
      end

      context "when file visibility is specified" do
        it "saves the file with the specified visibility" do
          expect(work_loader.curation_concern.file_sets.map(&:visibility)).to include("restricted")
        end
      end

      context "when editors are set" do
        let(:editors) { [create(:user).email, create(:user).email] }
        it "saves the work with the readers" do
          expect(work_loader.curation_concern.edit_users).to include(editors[0])
          expect(work_loader.curation_concern.edit_users).to include(editors[1])
        end
      end

      context "when a reader is set" do
        let(:readers) { create(:user).email }
        it "saves the work with the reader" do
          expect(work_loader.curation_concern.read_users).to include(readers)
        end
      end

      context "when a related work is set" do
        let(:related_work) { create(:article) }
        let(:member_work_ids) { related_work.id }
        it "saves the work with the relationship" do
          expect(work_loader.curation_concern.member_ids).to include(related_work.id)
        end
      end
    end
  end

  describe "Generic Work" do
    it_behaves_like "batch upload object" do
      let(:work_type) { "GenericWork" }
      let(:attributes) { default_attributes.merge(work_type: 'generic_work') }
    end
  end

  describe "Article" do
    it_behaves_like "batch upload object" do
      let(:work_type) { "Article" }
      let(:attributes) { default_attributes.merge(work_type: 'article') }
    end
  end

  describe "Document" do
    it_behaves_like "batch upload object" do
      let(:work_type) { "Document" }
      let(:attributes) { default_attributes.merge(work_type: 'document') }
    end
  end

  describe "Media" do
    it_behaves_like "batch upload object" do
      let(:work_type) { "Medium" }
      let(:attributes) { default_attributes.merge(work_type: 'medium') }
    end
  end

  describe "Image" do
    it_behaves_like "batch upload object" do
      let(:work_type) { "Image" }
      let(:attributes) { default_attributes.merge(work_type: 'image') }
    end
  end

  describe "Dataset" do
    it_behaves_like "batch upload object" do
      let(:work_type) { "Dataset" }
      let(:attributes) { default_attributes.merge(work_type: 'dataset', required_software: 'Minesweeper') }
    end
  end

  describe "Etd" do
    it_behaves_like "batch upload object" do
      let(:work_type) { "Etd" }
      # Use only 1 committee_member since fedora doesn't preserve the order
      let(:attributes) { default_attributes.merge(work_type: 'etd', advisor: ["Some advisor"], committee_member: ["member 1"]) }
    end
  end

  describe "Student Work" do
    it_behaves_like "batch upload object" do
      let(:work_type) { "StudentWork" }
      let(:attributes) { default_attributes.merge(work_type: 'student_work', advisor: ["Some advisor"]) }
    end
  end
end
