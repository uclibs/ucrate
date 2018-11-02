# frozen_string_literal: true
require 'rails_helper'

shared_examples "batch_form_fields" do |work_class|
  let(:work_form_class) { ("Hyrax::" + work_class.name + "Form").constantize }
  let(:work_name) { work_class.name }
  let(:batch) { Hyrax::Forms::BatchUploadForm.new(BatchUploadItem.new, nil, nil) }

  context "batch form" do
    let(:target) { work_form_class.new(work_class.new, nil, nil) }
    before { batch.payload_concern = work_name }

    describe "#required_fields" do
      it "equals the terms for the payload" do
        expect(batch.required_fields).to eq(target.required_fields)
      end
    end

    describe "#primary_terms" do
      it "equals the terms for the payload" do
        expect(batch.primary_terms).to eq(target.primary_terms - [:title])
      end
    end
  end
end

RSpec.describe Hyrax::Forms::BatchUploadForm do
  Hyrax.config.curation_concerns.each do |klass|
    it_behaves_like 'batch_form_fields', klass
  end

  let(:model) { GenericWork.new }
  let(:form) { described_class.new(model, ability, nil) }
  let(:ability) { Ability.new(user) }
  let(:user) { build(:user, display_name: 'Jill Z. User') }

  describe "#terms" do
    let(:terms) do
      %i[creator description license publisher date_created subject
         language identifier based_near related_url representative_id
         thumbnail_id files visibility_during_embargo embargo_release_date
         visibility_after_embargo visibility_during_lease
         lease_expiration_date visibility_after_lease visibility
         ordered_member_ids in_works_ids collection_ids admin_set_id
         alternate_title journal_title issn time_period required_software
         committee_member note geo_subject doi doi_assignment_strategy existing_identifier
         college department genre degree advisor]
    end

    subject { form.terms }
    it { is_expected.to eq terms }
  end
end
