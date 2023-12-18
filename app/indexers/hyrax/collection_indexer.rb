# frozen_string_literal: true
module Hyrax
  class CollectionIndexer < Hydra::PCDM::CollectionIndexer
    include Hyrax::IndexesThumbnails
    include SortableTitleIndexer

    STORED_LONG = ActiveFedora::Indexing::Descriptor.new(:long, :stored)

    self.thumbnail_path_service = Hyrax::CollectionThumbnailPathService

    def generate_solr_document
      super.tap do |solr_doc|
        # Makes Collections show under the "Collections" tab
        solr_doc['generic_type_sim'] = ["Collection"]
        # Index the size of the collection in bytes
        solr_doc['bytes'] = object.bytes
        solr_doc['thumbnail_path_ss'] = thumbnail_path
        solr_doc['visibility_ssi'] = object.visibility
        solr_doc['sort_title'] = sortable_title(object.title.first)  if object.title.present?

        object.in_collections.each do |col|
          (solr_doc['member_of_collection_ids_ssim'] ||= []) << col.id
          (solr_doc['member_of_collections_ssim'] ||= []) << col.to_s
        end
      end
    end
  end
end
