# frozen_string_literal: true
require 'rails_helper'
require 'spec_helper'

RSpec.describe 'hyrax/file_sets/show.html.erb', type: :view do
  let(:user) { instance_double(user_key: 'sarah', twitter_handle: 'test') }
  let(:ability) { double }
  let(:doc) do
    {
      "has_model_ssim" => ["FileSet"],
      :id => "123",
      "title_tesim" => ["My Title"]
    }
  end
  let(:solr_doc) { SolrDocument.new(doc) }
  let(:presenter) { Hyrax::FileSetPresenter.new(solr_doc, ability) }
  let(:mock_metadata) do
    {
      format: ["Tape"],
      long_term: ["x" * 255],
      multi_term: ["1", "2", "3", "4", "5", "6", "7", "8"],
      string_term: 'oops, I used a string instead of an array',
      logged_fixity_status: "Fixity checks have not yet been run on this file"
    }
  end

  let(:page) { Capybara::Node::Simple.new(rendered) }

  before do
    view.lookup_context.prefixes.push 'hyrax/base'
    allow(view).to receive(:can?).with(:edit, SolrDocument).and_return(false)
    allow(ability).to receive(:can?).with(:edit, SolrDocument).and_return(false)
    allow(presenter).to receive(:fixity_status).and_return(mock_metadata)
    allow(presenter).to receive(:mime_type).and_return('application/pdf')
    assign(:presenter, presenter)
    assign(:document, solr_doc)
    assign(:fixity_status, "none")
    render template: 'hyrax/file_sets/_show_pdf_helper'
    render template: 'hyrax/file_sets/show.html.erb'
  end

  it 'shows acrobat download link' do
    expect(rendered).to have_content "Download Adobe Acrobat Reader"
  end
end
