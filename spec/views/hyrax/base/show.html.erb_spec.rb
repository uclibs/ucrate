# frozen_string_literal: true
require 'rails_helper'
require 'spec_helper'

RSpec.describe 'hyrax/base/show.html.erb', type: :view do
  let(:work_solr_document) do
    SolrDocument.new(id: '999',
                     title_tesim: ['My Title'],
                     creator_tesim: ['Doe, John', 'Doe, Jane'],
                     date_modified_dtsi: '2011-04-01',
                     date_uploaded_dtsi: '1999-12-31',
                     has_model_ssim: ['GenericWork'],
                     depositor_tesim: depositor.user_key,
                     description_tesim: ['Lorem ipsum lorem ipsum.'],
                     rights_statement_tesim: ['http://example.org/rs/1'],
                     date_created_tesim: ['1984-01-02'])
  end

  let(:file_set_solr_document) do
    SolrDocument.new(id: '123',
                     title_tesim: ['My FileSet'],
                     depositor_tesim: depositor.user_key)
  end

  let(:user) { create(:user, groups: 'admin') }
  let(:ability) { Ability.new(user) }

  let(:presenter) do
    Hyrax::WorkShowPresenter.new(work_solr_document, ability, request)
  end

  let(:workflow_presenter) do
    instance_double('workflow_presenter', badge: 'Foobar')
  end

  let(:representative_presenter) do
    Hyrax::FileSetPresenter.new(file_set_solr_document, ability)
  end

  let(:page) { Capybara::Node::Simple.new(rendered) }

  let(:request) { instance_double('request', host: 'test.host') }

  let(:depositor) do
    stub_model(User,
               user_key: 'bob',
               twitter_handle: 'bot4lib')
  end

  let(:search_state) { instance_double('SearchState', params_for_search: {}) }

  before do
    allow(presenter).to receive(:workflow).and_return(workflow_presenter)
    allow(presenter).to receive(:representative_presenter).and_return(representative_presenter)
    allow(presenter).to receive(:representative_id).and_return('123')
    allow(presenter).to receive(:doi).and_return("doi:12.3456/FK2")
    allow(presenter).to receive(:tweeter).and_return("@#{depositor.twitter_handle}")
    allow(presenter).to receive(:human_readable_type).and_return("Work")
    allow(controller).to receive(:current_user).and_return(depositor)
    allow(User).to receive(:find_by_user_key).and_return(depositor.user_key)
    allow(view).to receive(:blacklight_config).and_return(Blacklight::Configuration.new)
    allow(view).to receive(:signed_in?)
    allow(view).to receive(:on_the_dashboard?).and_return(false)
    stub_template 'hyrax/base/_show_actions.html.erb' => ''
    stub_template 'hyrax/base/_metadata.html.erb' => ''
    stub_template 'hyrax/base/_relationships.html.erb' => ''
    stub_template 'hyrax/base/_social_media.html.erb' => ''
    stub_template 'hyrax/base/_citations.html.erb' => ''
    stub_template 'hyrax/base/_items.html.erb' => ''
    stub_template 'hyrax/base/_workflow_actions_widget.html.erb' => ''
    stub_template '_masthead.html.erb' => ''
    assign(:presenter, presenter)
    allow(presenter.representative_presenter).to receive(:mime_type).and_return('application/pdf')
    allow(view).to receive(:search_state).and_return(search_state)
    render template: 'hyrax/base/show.html.erb', layout: 'layouts/hyrax/1_column'
  end

  describe 'Mendeley' do
    it 'appears in meta tags' do
      mendeley_meta_tags = Nokogiri::HTML(rendered).xpath("//meta[contains(@name, 'DC.')]")
      expect(mendeley_meta_tags.count).to be >= 3
    end
    it 'displays title' do
      tag = Nokogiri::HTML(rendered).xpath("//meta[@name='DC.Title']")
      expect(tag.attribute('content').value).to eq('My Title')
    end
    it 'displays authors' do
      tags = Nokogiri::HTML(rendered).xpath("//meta[@name='DC.Creator']")
      expect(tags.first.attribute('content').value).to eq('Doe, John')
      expect(tags.last.attribute('content').value).to eq('Doe, Jane')
    end
    it 'displays description' do
      tag = Nokogiri::HTML(rendered).xpath("//meta[@name='DC.Description']")
      expect(tag.attribute('content').value).to eq('Lorem ipsum lorem ipsum.')
    end
  end

  it "displays download link for Adobe Acrobat" do
    expect(page).to have_text("Download Adobe Acrobat Reader")
  end

  it 'shows last modified and date uploaded' do
    expect(page).to have_text 'Date Uploaded: 12/31/1999'
    expect(page).to have_text 'Date Modified: 04/01/2011'
  end

  it "has the correct DOI header" do
    expect(page).to have_text 'Digital Object Identifier (DOI)'
  end
end
