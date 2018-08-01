# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'hyrax/base/relationships', type: :view do
  let(:user) { create(:user, groups: 'admin') }
  let(:ability) { Ability.new(user) }
  let(:solr_doc) { instance_double(SolrDocument, id: '123', human_readable_type: 'Work', admin_set: nil) }
  let(:presenter) { Hyrax::WorkShowPresenter.new(solr_doc, ability) }
  context "with admin sets" do
    it "renders using attribute_to_html" do
      allow(controller).to receive(:current_user).and_return(user)
      allow(solr_doc).to receive(:member_of_collection_ids).and_return([])
      expect(presenter).not_to receive(:attribute_to_html).with(:admin_set, render_as: :faceted, html_dl: true)
      render 'hyrax/base/relationships', presenter: presenter
    end
  end
end
