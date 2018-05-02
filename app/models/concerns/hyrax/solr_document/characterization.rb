# frozen_string_literal: true

require Hyrax::Engine.root.join('app/models/concerns/hyrax/solr_document/characterization.rb')
module Hyrax
  module SolrDocument
    module Characterization
      def sha1_checksum
        self['digest_ssim'].first.to_s.split(':').last
      end
    end
  end
end
