# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Hyrax::Renderers::AttributeRenderer do
  let(:field) { :note }
  let(:renderer) { described_class.new(field, [""]) }

  describe '#render' do
    let(:rendered) { Nokogiri::HTML(renderer.render) }
    let(:expected) { Nokogiri::HTML(tr_content) }
    let(:tr_content) { "" }

    it { expect(rendered).to be_equivalent_to(expected) }
  end
end
