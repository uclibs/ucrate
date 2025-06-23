# frozen_string_literal: true

# NOTE: This is a monkey patch of ActiveFedora::SolrService.
#
# Purpose:
#   Silence the following deprecation warning from rsolr 2.x:
#     DEPRECATION: Rsolr.new/connect option read_timeout is deprecated and will be removed in Rsolr 3.
#     timeout is currently a synonym, use that instead.
#
# Why we're patching:
#   - active-fedora 12.2.4 hardcodes `read_timeout`, which triggers this warning.
#   - rsolr 3.0+ removes `read_timeout` entirely and requires Ruby 3.1+, but our app is still on Ruby 2.x.
#   - Upgrading active-fedora or Ruby is non-trivial at this time due to wider dependency constraints.
#
# What this does:
#   - Overrides the default SolrService to replace `read_timeout` with the supported `timeout` option.
#
# When to remove:
#   - This patch can be removed once:
#       1. The app upgrades to Ruby 3.1 or higher
#       2. rsolr 3.x is compatible
#       3. active-fedora is upgraded to a version that no longer uses `read_timeout`
#
# See also:
#   - https://github.com/rsolr/rsolr/issues/222
#   - https://github.com/samvera/active_fedora

require 'rsolr'

module ActiveFedora
  class SolrService
    attr_reader :options
    attr_writer :conn

    MAX_ROWS = 10_000

    def initialize(options = {})
      @options = { timeout: 120, open_timeout: 120, url: 'http://localhost:8080/solr' }.merge(options)
    end

    def conn
      @conn ||= RSolr.connect @options
    end

    class << self
      # @param [Hash] options
      def register(options = {})
        ActiveFedora::RuntimeRegistry.solr_service = new(options)
      end

      def reset!
        ActiveFedora::RuntimeRegistry.solr_service = nil
      end

      def select_path
        ActiveFedora.solr_config.fetch(:select_path, 'select')
      end

      def instance
        # Register Solr

        register(ActiveFedora.solr_config) unless ActiveFedora::RuntimeRegistry.solr_service

        ActiveFedora::RuntimeRegistry.solr_service
      end

      def get(query, args = {})
        args = args.merge(q: query, qt: 'standard')
        SolrService.instance.conn.get(select_path, params: args)
      end

      def post(query, args = {})
        args = args.merge(q: query, qt: 'standard')
        SolrService.instance.conn.post(select_path, data: args)
      end

      def query(query, args = {})
        unless args.key?(:rows)
          Base.logger.warn "Calling ActiveFedora::SolrService.get without passing an explicit value for ':rows' is not recommended. You will end up with
Solr's default (usually set to 10)\nCalled by #{caller[0]}"
        end
        method = args.delete(:method) || :get

        result = case method
                 when :get
                   get(query, args)
                 when :post
                   post(query, args)
                 else
                   raise "Unsupported HTTP method for querying SolrService (#{method.inspect})"
                 end
        result['response']['docs'].map do |doc|
          ActiveFedora::SolrHit.new(doc)
        end
      end

      def delete(id)
        SolrService.instance.conn.delete_by_id(id, params: { 'softCommit' => true })
      end

      # Get the count of records that match the query
      # @param [String] query a solr query
      # @param [Hash] args arguments to pass through to `args' param of SolrService.query (note that :rows will be overwritten to 0)
      # @return [Integer] number of records matching
      def count(query, args = {})
        args = args.merge(rows: 0)
        SolrService.get(query, args)['response']['numFound'].to_i
      end

      # @param [Hash] doc the document to index, or an array of docs
      # @param [Hash] params
      #   :commit => commits immediately
      #   :softCommit => commit to memory, but don't flush to disk
      def add(doc, params = {})
        SolrService.instance.conn.add(doc, params: params)
      end

      def commit
        SolrService.instance.conn.commit
      end
    end
  end # SolrService
end # ActiveFedora
