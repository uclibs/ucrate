# frozen_string_literal: true

class IdentifierEmbargoUpdateJob < ActiveJob::Base
  def perform(identifier_uri)
    RestClient.put(post_uri(identifier_uri), "{\n  \"data\": {\n    \"type\": \"dois\",\n    \"attributes\": {\n      \"event\": \"publish\"\n    }\n  }\n}", content_type: :json)
  end

  private

    def post_uri(identifier_uri)
      u = URI.parse(identifier_uri)
      u.user = ENV["SCHOLAR_DOI_USERNAME"]
      u.password = ENV["SCHOLAR_DOI_PASSWORD"]
      u.to_s
    end
end
