# frozen_string_literal: true
require 'rails_helper'

describe 'hyrax/base/_attributes.html.erb' do
  let(:college) { 'Libraries' }
  let(:department) { 'Digital Repositories' }
  let(:related_url) { 'http://www.uc.edu' }
  let(:submitter) { FactoryBot.create(:user) }
  let(:journal_title) { 'UC Journal' }

  let(:solr_document) { SolrDocument.new(attributes) }
  let(:attributes) do
    {
      Solrizer.solr_name('has_model', :symbol) => ["GenericWork"],
      college_tesim: college,
      department_tesim: department,
      related_url_tesim: related_url,
      depositor_tesim: submitter.email,
      journal_title_tesim: journal_title
    }
  end
  let(:ability) { double(admin?: true) }
  let(:presenter) do
    Hyrax::WorkShowPresenter.new(solr_document, ability)
  end
  let(:doc) { Nokogiri::HTML(rendered) }

  before do
    allow(presenter).to receive(:member_of_collection_presenters).and_return([])
    allow(view).to receive(:dom_class) { '' }

    render 'hyrax/base/attributes', presenter: presenter
  end

  it 'has links to search for other objects with the same metadata' do
    expect(rendered).to have_link(related_url)
    expect(rendered).to have_link(href: hyrax.dashboard_profile_path(submitter))
  end
end
