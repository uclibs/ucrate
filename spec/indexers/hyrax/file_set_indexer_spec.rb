# frozen_string_literal: true
require 'rails_helper'

describe Hyrax::FileSetIndexer do
  include Hyrax::FactoryHelpers

  let(:file_set) do
    FileSet.new(id: 'foo123')
  end

  let(:mock_file) do
    mock_file_factory(
      file_size: ['5000000000000000000']
    )
  end

  let(:indexer) { described_class.new(file_set) }

  describe '#generate_solr_document' do
    before do
      allow(file_set).to receive(:label).and_return('CastoriaAd.tiff')
      allow(Hyrax::ThumbnailPathService).to receive(:call).and_return('/downloads/foo123?file=thumbnail')
      allow(file_set).to receive(:original_file).and_return(mock_file)
    end
    subject { indexer.generate_solr_document }

    it 'has a file_size field stored as a :long' do
      expect(subject[Solrizer.solr_name('file_size', Solrizer::Descriptor.new(:long, :stored))]).to eq '5000000000000000000'
    end
  end
end
