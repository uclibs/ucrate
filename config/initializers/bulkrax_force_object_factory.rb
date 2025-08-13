# frozen_string_literal: true

# -----------------------------------------------------------------------------
# Force Bulkrax to use a minimal, ActiveFedora-backed object factory
#
# Context / Why:
#   • Bulkrax (v9.x) expects an `object_factory` that implements BOTH:
#       - `.query(query_string, **kwargs)`  → search Solr
#       - `.find(id)`                       → fetch a single object by id
#   • In AF/Hyrax stacks without a Hyrax::SearchService wired up (or in
#     Sidekiq where Blacklight config may not be loaded), Bulkrax’s default
#     factory path can be nil or incomplete. That leads to exporter errors.
#
# What this initializer does:
#   • Defines `Bulkrax::SimpleSolrObjectFactory`, a tiny factory that:
#       - uses `ActiveFedora::SolrService.query` for Solr searches
#       - uses `ActiveFedora::Base.find` for fetching AF/Hyrax objects
#       - returns `nil` when an object is missing/tombstoned
#       - passes through objects that already look like AF models
#   • Sets `Bulkrax.object_factory` lazily to this simple factory and provides
#     a setter so you can override it elsewhere if you introduce a richer
#     implementation later.
#
# Notes:
#   • Works in all processes (web/console/Sidekiq) thanks to `to_prepare`.
#   • Pairs well with the separate “factory sanity” initializer that only
#     overrides the factory when it’s nil or missing required methods.
#   • If you replace this with a custom factory, ensure it responds to BOTH
#     `.query` and `.find`.
# -----------------------------------------------------------------------------

Rails.application.config.to_prepare do
  module Bulkrax
    module SimpleSolrObjectFactory
      module_function

      # Solr search (returns an array of Solr docs/hashes)
      def query(q, **kwargs)
        ActiveFedora::SolrService.query(q, **kwargs)
      end

      # Fetch AF/Hyrax object by id (works, collections, file sets)
      # - Pass-through if an object (responds_to :id) is provided
      # - Return nil if not found or tombstoned
      def find(id, **)
        return id if id.respond_to?(:id)
        ActiveFedora::Base.find(id.to_s)
      rescue ActiveFedora::ObjectNotFoundError, Ldp::Gone
        nil
      end
    end

    class << self
      # Default to the simple AF-backed factory unless explicitly overridden
      def object_factory
        @object_factory ||= Bulkrax::SimpleSolrObjectFactory
      end

      # Allow apps to swap in a richer object factory if desired
      attr_writer :object_factory
    end
  end
end
