# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Hyrax::Renderers::NoteRenderer do
  let(:field) { :note }
  let(:renderer) { described_class.new(field, "Line 1\nLine 2\n\nLine 4") }

  describe '#attribute_to_html' do
    let(:rendered) { Nokogiri::HTML(renderer.render) }
    let(:expected) { Nokogiri::HTML(tr_content) }

    let(:tr_content) do
      "<tr>\n" \
      "<th>Note</th>\n" \
      "<td><ul class='tabular'><li class='attribute attribute-note'>\n" \
      "<p>Line 1\n" \
      "<br>Line 2</p>\n\n" \
      "<p>Line 4</p>\n" \
      "</li></ul></td>\n" \
      "</tr></body></html>\n"
    end

    it { expect(rendered).to be_equivalent_to(expected) }
  end
end
