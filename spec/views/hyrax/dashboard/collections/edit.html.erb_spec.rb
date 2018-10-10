# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'hyrax/dashboard/collections/edit.html.erb', type: :view do
  let(:collection) { build(:collection, id: 'xyz123z4', title: ["Make Collections Great Again"]) }
  let(:form) { Hyrax::Forms::CollectionForm.new(collection, double, double) }

  before do
    assign(:collection, collection)
    assign(:form, form)
    stub_template '_form.html.erb' => 'my-edit-form partial'
    stub_template '_flash_msg.html.erb' => 'flash_msg partial'

    render
  end

  it 'displays the page' do
    expect(rendered).to have_content 'my-edit-form partial'
    expect(rendered).to have_content 'flash_msg partial'
  end
end
