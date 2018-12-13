# frozen_string_literal: true
require 'spec_helper'

describe Scholar do
  let(:curation_concern) { double(id: "abc123") }

  context '#permanent_url_for' do
    it {
      expect(described_class.permanent_url_for(curation_concern)).to eq(File.join(Rails.configuration.application_root_url, "/show/#{curation_concern.id}"))
    }
  end
end
