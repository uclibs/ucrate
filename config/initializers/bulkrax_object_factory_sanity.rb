# frozen_string_literal: true

# -----------------------------------------------------------------------------
# Bulkrax object_factory sanity check / safety net
#
# Why:
#   Bulkrax’s exporter expects `Bulkrax.object_factory` to implement BOTH:
#     - `.query(query_string, **kwargs)`  → SOLR search
#     - `.find(id)`                       → fetch a single record
#
#   In certain boots/reloads (e.g., dev code reloads, Sidekiq vs. web init order,
#   or future gem upgrades), `Bulkrax.object_factory` can end up `nil` or point to
#   something that doesn’t implement the full API. That leads to errors like:
#     - NoMethodError: undefined method `query' for nil:NilClass
#     - NoMethodError: undefined method `find' for <Factory>:Module
#
# What this does:
#   On each app prepare (boot + every code reload in development), if the current
#   factory is missing or incomplete, we set a safe default:
#   `Bulkrax::SimpleSolrObjectFactory` (which wraps ActiveFedora::SolrService).
#
# Notes:
#   • Non-invasive: if a valid custom factory is already set, we do NOTHING.
#   • Runs in all processes (web/console/Sidekiq) to prevent divergence.
#   • Assumes `Bulkrax::SimpleSolrObjectFactory` is defined elsewhere (e.g.,
#     in `config/initializers/bulkrax_force_object_factory.rb`) and provides:
#       def self.query(q, **kwargs); end
#       def self.find(id); end
#   • If you swap in your own factory, make sure it responds to BOTH `.query` and `.find`.
# -----------------------------------------------------------------------------

Rails.application.config.to_prepare do
  next unless defined?(Bulkrax)

  factory = Bulkrax.object_factory
  needs_default = factory.nil? ||
                  !factory.respond_to?(:query) ||
                  !factory.respond_to?(:find)

  if needs_default
    Bulkrax.object_factory = Bulkrax::SimpleSolrObjectFactory
    Rails.logger.info("[bulkrax] object_factory was nil/incomplete; defaulting to Bulkrax::SimpleSolrObjectFactory")
  end
end
