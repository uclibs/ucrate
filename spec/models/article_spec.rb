# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Article`
require 'rails_helper'

RSpec.describe Article do
  describe ".properties" do
    subject { described_class.properties.keys }

    it { is_expected.to include("has_model", "create_date", "modified_date") }
  end

  describe "basic metadata" do
    let(:props) { described_class.properties.keys }

    before do
      allow(props).to receive(:title).and_return(['foo'])
    end
    it "has dc properties" do
      expect(props.title).to eq ['foo']
    end
  end

  describe "delegations" do
    let(:work) { described_class.new { |gw| gw.apply_depositor_metadata("user") } }
    let(:proxy_depositor) { create(:user) }

    before do
      work.proxy_depositor = proxy_depositor.user_key
    end
    it "includes proxies" do
      expect(work).to respond_to(:relative_path)
      expect(work).to respond_to(:depositor)
      expect(work.proxy_depositor).to eq proxy_depositor.user_key
    end
  end

  describe "metadata" do
    it { is_expected.to respond_to(:relative_path) }
    it { is_expected.to respond_to(:depositor) }
    it { is_expected.to respond_to(:related_url) }
    it { is_expected.to respond_to(:creator) }
    it { is_expected.to respond_to(:title) }
    it { is_expected.to respond_to(:alternate_title) }
    it { is_expected.to respond_to(:journal_title) }
    it { is_expected.to respond_to(:issn) }
    it { is_expected.to respond_to(:description) }
    it { is_expected.to respond_to(:publisher) }
    it { is_expected.to respond_to(:time_period) }
    it { is_expected.to respond_to(:date_created) }
    it { is_expected.to respond_to(:date_uploaded) }
    it { is_expected.to respond_to(:date_modified) }
    it { is_expected.to respond_to(:subject) }
    it { is_expected.to respond_to(:geo_subject) }
    it { is_expected.to respond_to(:required_software) }
    it { is_expected.to respond_to(:note) }
    it { is_expected.to respond_to(:language) }
    it { is_expected.to respond_to(:identifier) }
    it { is_expected.to respond_to(:college) }
    it { is_expected.to respond_to(:department) }
  end
end
