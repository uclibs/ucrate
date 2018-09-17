# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Etd`
require 'rails_helper'

RSpec.describe Hyrax::EtdForm do
  let(:work) { Etd.new }
  let(:form) { described_class.new(work, nil, nil) }

  describe "#required_fields" do
    subject { form.required_fields }

    it { is_expected.to eq [:title, :creator, :college, :department, :description, :advisor, :license] }
  end

  describe "#primary_terms" do
    subject { form.primary_terms }

    it {
      is_expected.to eq [:title, :creator, :college, :department, :description, :advisor,
                         :license, :rights_statement, :committee_member, :degree, :date_created,
                         :publisher, :alternate_title, :genre, :subject, :geo_subject,
                         :time_period, :language, :required_software, :note, :related_url]
    }
  end

  describe "#[]" do
    subject { form[term] }

    context "for member_of_collection_ids" do
      let(:term) { :member_of_collection_ids }

      it { is_expected.to eq [] }

      context "when the model has collection ids" do
        before do
          allow(work).to receive(:member_of_collection_ids).and_return(['col1', 'col2'])
        end
        # This allows the edit form to show collections the work is already a member of.
        it { is_expected.to eq ['col1', 'col2'] }
      end
    end
  end

  describe '.model_attributes' do
    let(:permission_template) { create(:permission_template, source_id: source_id) }
    let!(:workflow) { create(:workflow, active: true, permission_template_id: permission_template.id) }
    let(:source_id) { '123' }
    let(:file_set) { create(:file_set) }

    let(:params) do
      ActionController::Parameters.new(
        title: 'foo',
        description: '',
        visibility: 'open',
        source_id: source_id,
        admin_set_id: '123',
        representative_id: '456',
        thumbnail_id: '789',
        rights_statement: 'http://creativecommons.org/licenses/by/4.0/us/',
        member_of_collection_ids: ['123456', 'abcdef']
      )
    end

    let(:attrib) { described_class.model_attributes(params) }

    it 'permits parameters' do
      expect(attrib['title']).to eq ['foo']
      expect(attrib['description']).to be_nil
      expect(attrib['visibility']).to eq 'open'
      expect(attrib['rights_statement']).to eq 'http://creativecommons.org/licenses/by/4.0/us/'
      expect(attrib['member_of_collection_ids']).to eq ['123456', 'abcdef']
    end

    context '.model_attributes' do
      let(:params) do
        ActionController::Parameters.new(
          title: '',
          description: '',
          rights_statement: '',
          member_of_collection_ids: [''],
          on_behalf_of: 'Melissa'
        )
      end

      let(:attrib) { described_class.model_attributes(params) }

      it 'removes blank parameters' do
        expect(attrib['title']).to be_nil
        expect(attrib['description']).to be_nil
        expect(attrib['rights_statement']).to be_nil
        expect(attrib['member_of_collection_ids']).to be_empty
        expect(attrib['on_behalf_of']).to eq 'Melissa'
      end
    end
  end

  describe "#visibility" do
    subject { form.visibility }

    it { is_expected.to eq 'open' }
  end

  subject { form }

  it { is_expected.to delegate_method(:on_behalf_of).to(:model) }
  it { is_expected.to delegate_method(:depositor).to(:model) }
  it { is_expected.to delegate_method(:permissions).to(:model) }

  describe "#agreement_accepted" do
    subject { form.agreement_accepted }

    it { is_expected.to eq false }
  end

  context "on a work already saved" do
    before { allow(work).to receive(:new_record?).and_return(false) }
    it "defaults deposit agreement to true" do
      expect(form.agreement_accepted).to eq(true)
    end
  end
end
