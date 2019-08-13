# frozen_string_literal: true

class IdentifierDeleteJob < ActiveJob::Base
  def perform(identifier_uri)
    state = get_state(identifier_uri)

    if state == "draft"
      RestClient.delete post_uri(identifier_uri)
    else
      RestClient.put(post_uri(identifier_uri), "{\n  \"data\": {\n    \"type\": \"dois\",\n    \"attributes\": {\n      \"event\": \"hide\",\n   \"url\": \"https://datacite.org/invalid.html\"\n    }\n  }\n}", content_type: :json)
    end
  end

  private

    def datacite_resource(identifier_uri)
      RestClient::Resource.new identifier_uri, ENV["SCHOLAR_DOI_USERNAME"], ENV["SCHOLAR_DOI_PASSWORD"]
    end

    def post_uri(identifier_uri)
      u = URI.parse(identifier_uri)
      u.user = ENV["SCHOLAR_DOI_USERNAME"]
      u.password = ENV["SCHOLAR_DOI_PASSWORD"]
      u.to_s
    end

    def doi_remote_service
      @doi_remote_service ||= Hydra::RemoteIdentifier.remote_service(:doi)
    end

    def get_state(identifier_uri)
      response = JSON.parse(datacite_resource(identifier_uri).get)
      response["data"]["attributes"]["state"]
    end
end
