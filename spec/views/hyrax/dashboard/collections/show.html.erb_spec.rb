# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'hyrax/dashboard/collections/show.html.erb', type: :view do
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

  let(:user) { create(:user, groups: 'admin') }
  let(:ability) { Ability.new(user) }
  let(:collection) { mock_model(::Collection) }
  let(:presenter) { Hyrax::CollectionPresenter.new(document, ability) }
  let(:collection_type) { double }
  let(:blacklight_config) { CatalogController.new.blacklight_config }
  let(:blacklight_configuration_context) do
    Blacklight::Configuration::Context.new(controller)
  end

  before do
    user = stub_model(User)
    allow(document).to receive(:hydra_model).and_return(::Collection)
    allow(view).to receive(:current_user).and_return(user)
    allow(view).to receive(:can?).with(:edit, document).and_return(true)
    allow(view).to receive(:can?).with(:destroy, document).and_return(true)
    allow(view).to receive(:current_ability).and_return(ability)
    allow(ability).to receive(:current_user).and_return(user)

    allow(Collection).to receive(:find).with(document.id).and_return(collection)

    allow(presenter).to receive(:total_items).and_return(0)
    allow(presenter).to receive(:collection_type).and_return(collection_type)
    allow(presenter).to receive(:subcollection_count).and_return(0)
    allow(presenter).to receive(:total_parent_collections).and_return(1)
    assign(:collection_type_is_nestable, true)
    assign(:subcollection_count, 1)
    assign(:total_parent_collections, 1)
    assign(:parent_collection_count, 1)
    assign(:members_count, 1)

    allow(collection_type).to receive(:nestable?).and_return(true)
    allow(collection_type).to receive(:title).and_return("User Collection")
    allow(collection_type).to receive(:badge_color).and_return("#ffa510")

    assign(:presenter, presenter)
    # Stub route because view specs don't handle engine routes
    allow(view).to receive(:blacklight_config).and_return(Blacklight::Configuration.new)
    allow(view).to receive(:blacklight_configuration_context).and_return(blacklight_configuration_context)
    allow(view).to receive(:edit_dashboard_collection_path).and_return("/dashboard/collection/123/edit")
    allow(view).to receive(:dashboard_collection_path).and_return("/dashboard/collection/123")
    allow(view).to receive(:collection_path).and_return("/collection/123")

    stub_template 'hyrax/collections/_search_form.html.erb' => 'search form'
    stub_template 'hyrax/dashboard/collections/_sort_and_per_page.html.erb' => 'sort and per page'
    stub_template '_document_list.html.erb' => 'document list'
    # This is tested ./spec/views/hyrax/dashboard/collections/_show_actions.html.erb_spec.rb
    stub_template '_show_actions.html.erb' => '<div class="stubbed-actions">THE COLLECTION ACTIONS</div>'
    stub_template '_show_subcollection_actions.html.erb' => '<div class="stubbed-actions">THE SUBCOLLECTION ACTIONS</div>'
    stub_template '_show_add_items_actions.html.erb' => '<div class="stubbed-actions">THE ADD ITEMS ACTIONS</div>'
    stub_template 'hyrax/dashboard/collections/_show_parent_collections.html.erb' => '<div class="stubbed-actions">Parent Collections</div>'
    stub_template '_subcollection_list.html.erb' => '<div class="stubbed-actions">Sub Collections</div>'
    stub_template 'hyrax/collections/_paginate.html.erb' => 'paginate'
    stub_template 'hyrax/collections/_media_display.html.erb' => '<span class="fa fa-cubes collection-icon-search"></span>'
    stub_template 'hyrax/my/collections/_modal_add_to_collection.html.erb' => 'modal add as subcollection'
    stub_template 'hyrax/my/collections/_modal_add_subcollection.html.erb' => 'modal add as parent'
  end

  context 'when the rendered collection has parent collection' do
    it 'renders parent followed by sub collections' do
      render
      # Making sure that we are verifying that the _show_actions.html.erb is rendering
      expect(rendered).to match(/.*Search Results within this Collection.*Parent Collections .*Sub Collections.*/m)
      expect(rendered).to have_text('Parent Collections (1)')
      expect(rendered).to have_text('Subcollections (1)')
    end
  end

  context 'when the rendered collection has a sub-collection' do
    before do
      assign(:subcollection_count, 1)
      assign(:total_parent_collections, 0)
      allow(presenter).to receive(:total_parent_collections).and_return(0)
    end
    it 'renders only sub collections' do
      render
      # Making sure that we are verifying that the _show_actions.html.erb is rendering
      expect(rendered).not_to match(/.*Search Results within this Collection.*Parent Collections .*Sub Collections.*/m)
      expect(rendered).to match(/.*Search Results within this Collection.*Sub Collections.*/m)
      expect(rendered).not_to have_text('Parent Collections')
      expect(rendered).to have_text('Subcollections (1)')
    end
  end
end
