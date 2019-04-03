# frozen_string_literal: true

class IdentifierDeleteJob < ActiveJob::Base
  def perform(identifier_uri)
    RestClient.put(post_uri(identifier_uri), "{\n  \"data\": {\n    \"type\": \"dois\",\n    \"attributes\": {\n      \"event\": \"hide\",\n   \"url\": \"https://datacite.org/invalid.html\"\n    }\n  }\n}", content_type: :json)
  end

  private

    def post_uri(identifier_uri)
      u = URI.parse(identifier_uri)
      u.user = doi_remote_service.username
      u.password = doi_remote_service.password
      u.to_s
    end

    def doi_remote_service
      @doi_remote_service ||= Hydra::RemoteIdentifier.remote_service(:doi)
    end
end
