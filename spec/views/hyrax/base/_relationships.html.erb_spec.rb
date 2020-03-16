# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'hyrax/base/relationships', type: :view do
  let(:user) { create(:user, groups: 'admin') }
  let(:ability) { Ability.new(user) }
  let(:solr_doc) { instance_double(SolrDocument, id: '123', human_readable_type: 'Work', admin_set: nil) }
  let(:presenter) { Hyrax::WorkShowPresenter.new(solr_doc, ability) }
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

  let(:presenter_types) { ["generic_work", "article", "document", "dataset", "image", "medium", "student_work", "etd", "collection"] }

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
  context "with admin sets" do
    it "renders using attribute_to_html" do
      allow(controller).to receive(:current_user).and_return(user)
      allow(presenter).to receive(:presenter_types).and_return([])
      allow(solr_doc).to receive(:member_of_collection_ids).and_return([])
      allow(presenter).to receive(:grouped_presenters).and_return({})
      expect(presenter).to receive(:attribute_to_html).with(:admin_set, render_as: :faceted, html_dl: true)
      render 'hyrax/base/relationships', presenter: presenter
    end
  end
end
