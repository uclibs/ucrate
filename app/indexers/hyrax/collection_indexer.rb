# frozen_string_literal: true
module Hyrax
  class CollectionIndexer < Hydra::PCDM::CollectionIndexer
    include Hyrax::IndexesThumbnails
    STORED_LONG = Solrizer::Descriptor.new(:long, :stored)

    self.thumbnail_path_service = Hyrax::CollectionThumbnailPathService

    def generate_solr_document
      super.tap do |solr_doc|
        # Makes Collections show under the "Collections" tab
        Solrizer.set_field(solr_doc, 'generic_type', 'Collection', :facetable)
        # Index the size of the collection in bytes
        solr_doc[Solrizer.solr_name(:bytes, STORED_LONG)] = object.bytes
        solr_doc['thumbnail_path_ss'] = thumbnail_path
        solr_doc['visibility_ssi'] = object.visibility
        Solrizer.insert_field(solr_doc, 'sort_title', sortable_title(object.title.first), :stored_sortable) if object.title && !object.title.empty?

        object.in_collections.each do |col|
          (solr_doc['member_of_collection_ids_ssim'] ||= []) << col.id
          (solr_doc['member_of_collections_ssim'] ||= []) << col.to_s
        end
      end
    end

    private

      def sortable_title(title)
        unless title.nil?
          cleaned_title = title.sub(/^\s+/i, "") # remove leading spaces
          cleaned_title.gsub!(/[^\w\s]/, "") # remove punctuation; preserve spaces and A-z 0-9
          cleaned_title.gsub!(/\s{2,}/, " ") # remove multiple spaces
          cleaned_title.sub!(/^(a |an |the )/i, "") # remove leading english articles
          cleaned_title.upcase! # upcase everything
          add_leading_zeros_to cleaned_title
        end
      end

      def add_leading_zeros_to(title)
        leading_number = title.match(/^\d+/)
        return title if leading_number.nil?
        title.sub(/^\d+/, leading_number[0].rjust(20, "0"))
      end
  end
end
