# frozen_string_literal: true
module RemotelyIdentifiedByDoi
  NOT_NOW = 'not_now'
  ALREADY_GOT_ONE = 'already_got_one'

  # What does it mean to be remotely assignable; Exposing the attributes
  module Attributes
    extend ActiveSupport::Concern
    included do
      before_destroy :withdraw_identifier
      property :doi, predicate: ::RDF::URI.new('http://purl.org/dc/terms/identifier#managedDOI'), multiple: false do |index|
        index.as :stored_searchable
      end

      property :identifier_url, predicate: ::RDF::URI.new('http://purl.org/dc/terms/identifier#doiManagementURI'), multiple: false
      property :identifier_status, predicate: ::RDF::URI.new('http://purl.org/dc/terms/identifier#doiStatus'), multiple: false
      property :existing_identifier, predicate: ::RDF::URI.new('http://purl.org/dc/terms/identifier#unmanagedDOI'), multiple: false

      validates :publisher, presence: { message: 'is required for remote DOI minting', if: :remote_doi_assignment_strategy? }

      attr_accessor :doi_assignment_strategy
      attr_writer :doi_remote_service

      def doi_status
        if visibility == Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
          "publish"

        #       This was part of the EZID environment.  Not sure if it is still needed with Datacite DOIs
        #       elsif locally_managed_remote_identifier? && identifier_status != "registered"
        #         "register"
        else
          "hide"
        end
      end

      def locally_managed_remote_identifier?
        return true unless identifier_url.nil?
        false
      end

      protected

        def doi_remote_service
          @doi_remote_service ||= Hydra::RemoteIdentifier.remote_service(:doi)
        end

        def remote_doi_assignment_strategy?
          doi_assignment_strategy.to_s == doi_remote_service.accessor_name.to_s
        end

      private

        def withdraw_identifier
          IdentifierDeleteJob.perform_later(identifier_url) unless identifier_url.blank?
        end
    end
  end

  module MintingBehavior
    def apply_doi_assignment_strategy(&perform_persistence_block)
      if respond_to?(:doi_assignment_strategy) && respond_to?(:identifier_url)
        if identifier_url.nil?
          perform_strategy(&perform_persistence_block)
        else
          yield(self) && identifier_request
        end

      else
        yield(self)
      end
    end

    private

      def perform_strategy(&perform_persistence_block)
        no_doi_assignment_strategy_given(&perform_persistence_block) ||
          not_now(&perform_persistence_block) ||
          update_identifier_locally(&perform_persistence_block) ||
          request_remote_minting_for(&perform_persistence_block)
      end

      def request_remote_minting_for
        return false unless remote_doi_assignment_strategy?
        # Before we make a potentially expensive call
        # hand off control back to the caller.
        # I'm doing this because I want a chance to persist the object first
        yield(self) && identifier_request
      end

      def identifier_request
        doi_remote_service.mint(self)
      end

      def update_identifier_locally
        return false unless doi_assignment_strategy == RemotelyIdentifiedByDoi::ALREADY_GOT_ONE
        # I'm doing this because before I persist, I want to update the
        # identifier
        self.doi = existing_identifier
        yield(self)
      end

      def no_doi_assignment_strategy_given
        return false unless doi_assignment_strategy.blank?
        yield(self)
      end

      def not_now
        return false unless doi_assignment_strategy.to_s == RemotelyIdentifiedByDoi::NOT_NOW
        self.doi = nil
        self.existing_identifier = nil
        yield(self)
      end
  end
end
