# frozen_string_literal: true
module Hyrax
  class WorkIndexer < ActiveFedora::IndexingService
    include Hyrax::IndexesThumbnails
    include Hyrax::IndexesWorkflow

    self.thumbnail_path_service = Hyrax::WorkThumbnailPathService
    def generate_solr_document
      super.tap do |solr_doc|
        solr_doc['member_ids_ssim'] = object.member_ids
        solr_doc['member_of_collections_ssim']    = object.member_of_collections.map(&:first_title)
        solr_doc['member_of_collection_ids_ssim'] = object.member_of_collections.map(&:id)
        Solrizer.set_field(solr_doc, 'generic_type', 'Work', :facetable)

        # This enables us to return a Work when we have a FileSet that matches
        # the search query.  While at the same time allowing us not to return Collections
        # when a work in the collection matches the query.
        solr_doc['file_set_ids_ssim'] = solr_doc['member_ids_ssim']
        solr_doc['visibility_ssi'] = object.visibility

        admin_set_label = object.admin_set.to_s
        solr_doc['admin_set_sim']   = admin_set_label
        solr_doc['admin_set_tesim'] = admin_set_label
        Solrizer.insert_field(solr_doc, 'sort_title', sortable_title(object.title.first), :stored_sortable) if object.title && !object.title.empty?
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
