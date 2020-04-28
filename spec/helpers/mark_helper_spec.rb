# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MarkHelper, type: :helper do
  let(:search_params) { ["Make", "test"] }
  let(:input_text) { "Make Collections Great Again" }

  describe '#catalog' do
    before do
      controller.params[:q] = 'make'
      allow(search_params).to receive(:length) { 2 }
      ActionController::Parameters.new(q: 'Make test')
    end
    it "returns expected output" do
      expect(catalog(input_text.dup)).to include('<mark>Make</mark>')
    end
  end

  describe '#catalog' do
    before do
      controller.params[:q] = 'testit'
      allow(search_params).to receive(:length) { 2 }
      ActionController::Parameters.new(q: 'Make test')
    end
    it "returns expected output" do
      expect(catalog(input_text.dup)).not_to include('<mark>')
    end
  end
end
