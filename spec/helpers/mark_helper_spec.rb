# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MarkHelper, type: :helper do
  let(:filter_chars) { ["Make", "test"] }
  let(:input_text) { "Make Collections Great Again" }
  before do
    controller.params[:q] = 'Make'
    allow(filter_chars).to receive(:length) { 2 }
    ActionController::Parameters.new(q: 'Make test')
  end

  describe '#catalog' do
    it "returns expected output" do
      expect(catalog(input_text.dup)).to include('<mark>Make</mark>')
    end
  end
end
