# frozen_string_literal: true

require Hyrax::Engine.root.join('app/forms/hyrax/forms/batch_upload_form.rb')

module Hyrax
  module Forms
    class BatchUploadForm < Hyrax::Forms::WorkForm
      self.terms = %i[creator description license publisher
                      date_created subject language identifier based_near related_url representative_id
                      thumbnail_id files visibility_during_embargo embargo_release_date
                      visibility_after_embargo visibility_during_lease
                      lease_expiration_date visibility_after_lease visibility
                      ordered_member_ids in_works_ids collection_ids admin_set_id
                      alternate_title journal_title issn time_period required_software
                      committee_member note geo_subject doi doi_assignment_strategy
                      existing_identifier college department genre degree advisor]

      def required_fields
        case @payload_concern
        when "Dataset"
          %i[title creator college department description required_software license]
        when "Etd"
          %i[title creator college department description advisor license]
        when "StudentWork"
          %i[title creator college department description advisor license]
        else
          %i[title creator college department description license]
        end
      end

      def primary_terms
        case @payload_concern
        when "Dataset"
          %i[creator college department description required_software license
             publisher date_created alternate_title subject geo_subject
             time_period language note related_url]
        when "StudentWork"
          %i[creator college department description advisor license
             degree publisher date_created alternate_title genre subject geo_subject
             time_period language required_software note related_url]
        when "Etd"
          %i[creator college department description advisor
             license committee_member degree date_created publisher
             alternate_title genre subject geo_subject time_period
             language required_software note related_url]
        when "Article"
          %i[creator college department description license publisher
             date_created alternate_title journal_title issn subject
             geo_subject time_period language required_software note related_url]
        when "Document"
          %i[creator college department description license publisher
             date_created alternate_title genre subject geo_subject
             time_period language required_software note related_url]
        when "Image"
          %i[creator college department description license publisher
             date_created alternate_title genre subject geo_subject
             time_period language required_software note related_url]
        when "Medium"
          %i[creator college department description license publisher
             date_created alternate_title subject geo_subject
             time_period language required_software note related_url]
        else
          %i[creator college department description license publisher
             date_created alternate_title subject geo_subject
             time_period language required_software note related_url]
        end
      end

      def secondary_terms
        []
      end
    end
  end
end
