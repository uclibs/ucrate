# frozen_string_literal: true

class IdentifierDeleteJob < ActiveJob::Base
  def perform(identifier_uri)
    RestClient.post(
      post_uri(identifier_uri),
      "_status: unavailable",
      content_type: :text
    )
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
