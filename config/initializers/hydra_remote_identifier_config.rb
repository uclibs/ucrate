# frozen_string_literal: true
# Register and configure remote identifiers for persisted objects
Hydra::RemoteIdentifier.configure do |config|
  doi_credentials = YAML.safe_load(ERB.new(File.read(Rails.root.join('config', 'doi.yml'))).result)[Rails.env]
  config.remote_service(:doi, doi_credentials) do |doi|
    doi.register(Article, Dataset, Document, Etd, Image, GenericWork, StudentWork, Medium) do |map|
      map.target { |obj| Scholar.permanent_url_for(obj) }
      map.status :doi_status
      map.creator :creator
      map.title :title
      map.publisher { |o| Array(o.publisher).join("; ") }
      map.publicationyear { |o| o.date_uploaded.year }
      map.identifier_url :identifier_url
      # Make sure that this method both sets the identifier and persists the change!
      map.set_identifier do |o, value|
        o.identifier_status = o.doi_status
        o.doi = value.fetch(:identifier)
        o.identifier_url = value.fetch(:identifier_url)
        o.save
      end
    end
  end
end
