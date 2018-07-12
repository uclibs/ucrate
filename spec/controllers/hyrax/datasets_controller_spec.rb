# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work Dataset`
require 'rails_helper'

RSpec.describe Hyrax::DatasetsController do
  let(:user) { create(:user) }
  let(:actor) { controller.send(:actor) }

  before do
    sign_in user
  end

  it "has dataset flash message" do
    get 'new'
    expect(flash[:notice]).to match("If you would like guidance on submitting a dataset, please read the <a href=\"/documenting_data\" target=\"_blank\">Documenting Data</a> help page.")
  end
end
