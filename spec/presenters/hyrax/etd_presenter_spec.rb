# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Etd`
require 'rails_helper'

RSpec.describe Hyrax::EtdPresenter do
  let(:solr_document) { SolrDocument.new(work.to_solr) }
  let(:presenter) { described_class.new(solr_document, ability) }

  subject { described_class.new(double, double) }
  it { is_expected.to delegate_method(:title).to(:solr_document) }
  it { is_expected.to delegate_method(:alternate_title).to(:solr_document) }
  it { is_expected.to delegate_method(:time_period).to(:solr_document) }
  it { is_expected.to delegate_method(:required_software).to(:solr_document) }
  it { is_expected.to delegate_method(:note).to(:solr_document) }
  it { is_expected.to delegate_method(:advisor).to(:solr_document) }
  it { is_expected.to delegate_method(:college).to(:solr_document) }
  it { is_expected.to delegate_method(:department).to(:solr_document) }
  it { is_expected.to delegate_method(:degree).to(:solr_document) }
  it { is_expected.to delegate_method(:etd_publisher).to(:solr_document) }
  it { is_expected.to delegate_method(:committee_member).to(:solr_document) }
end
