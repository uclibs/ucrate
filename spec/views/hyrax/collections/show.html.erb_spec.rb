# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'hyrax/collections/show.html.erb', type: :view do
  let(:parentdocument) do
    SolrDocument.new(id: 'xyz123z4',
                     'title_tesim' => ['Make Collections Great Again'],
                     'rights_tesim' => ["http://creativecommons.org/licenses/by-sa/3.0/us/"])
  end

  let(:document) do
    SolrDocument.new(id: 'zyx365z4',
                     'title_tesim' => ['Make Collections Great Again'],
                     'rights_tesim' => ["http://creativecommons.org/licenses/by-sa/3.0/us/"],
                     'member_of_collection_ids_ssim' => ['xyz123z4'])
  end
  let(:ability) { double }
  let(:collection_type) { create(:collection_type) }
  let(:presenter) { Hyrax::CollectionPresenter.new(document, ability) }
  let(:blacklight_config) { CatalogController.new.blacklight_config }
  let(:blacklight_configuration_context) do
    Blacklight::Configuration::Context.new(controller)
  end

  before do
    allow(document).to receive(:hydra_model).and_return(::Collection)
    allow(controller).to receive(:current_user).and_return(stub_model(User))
    allow(view).to receive(:can?).with(:edit, document).and_return(false)
    allow(view).to receive(:can?).with(:destroy, document).and_return(false)
    allow(presenter).to receive(:collection_type_is_nestable?).and_return(true)
    allow(presenter).to receive(:total_viewable_items).and_return(0)
    allow(presenter).to receive(:banner_file).and_return("banner.gif")
    allow(presenter).to receive(:logo_record).and_return([{ linkurl: "logo link url", alttext: "logo alt text", file_location: "logo.gif" }])
    allow(presenter).to receive(:total_items).and_return(0)
    allow(presenter).to receive(:collection_type).and_return(collection_type)
    allow(presenter).to receive(:subcollection_count).and_return(1)
    allow(presenter).to receive(:total_parent_collections).and_return(1)
    assign(:collection_type_is_nestable, true)
    assign(:subcollection_count, 1)
    assign(:total_parent_collections, 1)
    assign(:parent_collection_count, 1)
    assign(:members_count, 1)

    assign(:has_collection_search_parameters, true)
    allow(ability).to receive(:user_groups).and_return([])
    allow(ability).to receive(:current_user).and_return(build(:user, id: nil, email: ""))
    assign(:presenter, presenter)

    allow(view).to receive(:blacklight_config).and_return(Blacklight::Configuration.new)
    allow(view).to receive(:blacklight_configuration_context).and_return(blacklight_configuration_context)

    # Stub route because view specs don't handle engine routes
    allow(view).to receive(:collection_path).and_return("/collections/123")

    stub_template 'hyrax/collections/_search_form.html.erb' => 'Search Results within this Collection'
    stub_template 'hyrax/collections/_sort_and_per_page.html.erb' => 'sort and per page'
    stub_template 'hyrax/collections/_document_list.html.erb' => 'document list'
    stub_template 'hyrax/collections/_paginate.html.erb' => 'paginate'
    stub_template 'hyrax/collections/_media_display.html.erb' => '<span class="fa fa-cubes collection-icon-search"></span>'
    stub_template 'hyrax/collections/_show_parent_collections.html.erb' => '<div class="stubbed-actions">Parent Collections</div>'
    stub_template '_subcollection_list.html.erb' => '<div class="stubbed-actions">Sub Collections</div>'
  end

  context 'when the rendered collection has parent collection' do
    it 'renders parent followed by sub collections' do
      render
      # Making sure that we are verifyicng that the _show_actions.html.erb is rendering
      expect(rendered).to match(/.*Search Results within this Collection.*Parent Collections .*Sub Collections.*/m)
      expect(rendered).to have_text('Parent Collections (1)')
      expect(rendered).to have_text('Subcollections (1)')
    end
  end

  context 'when the rendered collection has a sub-collection' do
    before do
      assign(:subcollection_count, 1)
      assign(:total_parent_collections, 0)
      assign(:has_collection_search_parameters, true)
      allow(presenter).to receive(:total_parent_collections).and_return(0)
    end
    it 'renders only sub collections' do
      render
      # Making sure that we are verifying that the _show_actions.html.erb is rendering
      expect(rendered).to match(/.*Search Results within this Collection.*Sub Collections.*/m)
      expect(rendered).not_to have_text('Parent Collections')
      expect(rendered).to have_text('Subcollections (1)')
    end
  end
end
