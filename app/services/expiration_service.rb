# frozen_string_literal: true

class ExpirationService
  attr_reader :expiration_date

  # @param [Date] date the date by which to measure expirations. Defaults to today.
  def self.call(date = Time.zone.today)
    new(date).run
  end

  # Set the expiration data such that it can be used in a solr query
  def initialize(date)
    @expiration_date = date.strftime('%Y-%m-%dT00:00:00Z')
  end

  def run
    expire_embargoes(Hyrax.config.registered_curation_concern_types.collect(&:constantize))
    expire_embargoes([FileSet])
  end

  def expire_embargoes(object_types)
    embargo_expirations(object_types).each do |expiration|
      next unless expiration.embargo.active?
      expiration.visibility = expiration.embargo.visibility_after_embargo
      if expiration.respond_to? :doi
        if expiration.doi.present?
          temp_doi = expiration.doi.at(4..-1)
          IdentifierEmbargoUpdateJob.perform_now("https://api.test.datacite.org/dois/" + temp_doi)
        end
      end
      expiration.deactivate_embargo!
      expiration.embargo.save
      expiration.save
      VisibilityCopyJob.perform_later(expiration) unless expiration.class == FileSet
    end
  end

  def embargo_expirations(object_types)
    curation_objects = []
    object_types.each do |type_class|
      type_class.where("embargo_release_date_dtsi:[* TO #{RSolr.solr_escape(expiration_date)}]").each { |curation_concern| curation_objects << curation_concern }
    end
    curation_objects
  end
end
