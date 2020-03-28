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

  let(:solr_doc) { instance_double(SolrDocument, id: '123', human_readable_type: 'Work', admin_set: nil) }
  let(:presenter) { Hyrax::WorkShowPresenter.new(solr_doc, ability) }

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

  let(:solr_doc) { instance_double(SolrDocument, id: '123', human_readable_type: 'Work', admin_set: nil) }

  let(:generic_work) do
    Hyrax::WorkShowPresenter.new(
      SolrDocument.new(
        id: '456',
        has_model_ssim: ['GenericWork'],
        title_tesim: ['Containing work']
      ),
      ability
    )
  end

  let(:collection) do
    Hyrax::CollectionPresenter.new(
      SolrDocument.new(
        id: '345',
        has_model_ssim: ['Collection'],
        title_tesim: ['Containing collection']
      ),
      ability
    )
  end
  let(:blacklight_config) { CatalogController.blacklight_config }
  let(:search_state) { Hyrax::SearchState.new(params, blacklight_config, controller) }

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

  context "when no parent collection/works are present" do
    let(:member_of_collection_presenters) { [] }
    let(:presenter_types) {["generic_work", "article", "document", "dataset", "image", "medium", "student_work", "etd", "collection"]}

    before do
      allow(view).to receive(:search_state).and_return(search_state)
      allow(controller).to receive(:current_user).and_return user
      allow(view).to receive(:contextual_path).and_return("/collections/456")
      allow(presenter).to receive(:presenter_types).and_return(presenter_types)
      allow(presenter).to receive(:member_of_collection_presenters).and_return(member_of_collection_presenters)
      render 'hyrax/base/relationships', presenter: presenter
    end
    it "displays only the work/collection" do
      expect(rendered).not_to match(/.*Digital Object Identifier (DOI).*Relationships .*/m)
      expect(page).not_to have_text 'In Collection'
      expect(page).not_to have_link 'Containing collection'
      expect(page).not_to have_text 'In Generic work'
    end
  end

  context "when collections are present and no parents are present" do
    let(:member_of_collection_presenters) { [collection] }
    let(:presenter_types) {["generic_work", "article", "document", "dataset", "image", "medium", "student_work", "etd", "collection"]}

    before do
      allow(view).to receive(:search_state).and_return(search_state)
      allow(controller).to receive(:current_user).and_return user
      allow(view).to receive(:contextual_path).and_return("/collections/456")
      allow(presenter).to receive(:presenter_types).and_return(presenter_types)
      allow(presenter).to receive(:member_of_collection_presenters).and_return(member_of_collection_presenters)
      render 'hyrax/base/relationships', presenter: presenter
    end
    it "links to collections" do
      expect(page).to have_text 'Relationships'
      expect(page).to have_text 'In Collection'
      expect(page).to have_link 'Containing collection'
      expect(page).not_to have_text 'In Generic work'
    end
  end

  context "when parents are present and collections are present" do
    let(:member_of_collection_presenters) { [generic_work, collection] }

    before do
      allow(view).to receive(:search_state).and_return(search_state)
      allow(controller).to receive(:current_user).and_return user
      allow(view).to receive(:contextual_path).and_return("/concern/generic_works/456")
      allow(presenter).to receive(:member_of_collection_presenters).and_return(member_of_collection_presenters)
      render 'hyrax/base/relationships', presenter: presenter
    end
    it "links to work and collection" do
      expect(page).to have_text 'Relationships'
      expect(page).to have_link 'Containing work'
      expect(page).to have_link 'Containing collection'
    end
  end
end
