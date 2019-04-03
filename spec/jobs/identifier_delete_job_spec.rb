# frozen_string_literal: true
require 'rails_helper'

describe IdentifierDeleteJob do
  let(:doi_remote_service) do
    double("Doi Remote Service", username: "foo", password: "bar")
  end

  let(:identifier_uri) { "https://www.example.com" }
  let(:expected_post_uri) { "https://foo:bar@www.example.com" }

  before do
    allow(Hydra::RemoteIdentifier).to receive(:remote_service).and_return(doi_remote_service)
  end

  describe "#perform" do
    it "calls RestClient with the correct params" do
      expect(RestClient).to receive(:put).with(
        expected_post_uri,
        "{\n  \"data\": {\n    \"type\": \"dois\",\n    \"attributes\": {\n      \"event\": \"hide\",\n   \"url\": \"https://datacite.org/invalid.html\"\n    }\n  }\n}",
        content_type: :json
      )

      described_class.perform_now(identifier_uri)
    end
  end
end
