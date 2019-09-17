
# frozen_string_literal: true
require 'rails_helper'

describe IdentifierEmbargoUpdateJob do
  let(:doi_remote_service) do
    double("Doi Remote Service", username: "foo", password: "bar")
  end

  let(:identifier_uri) { "https://api.test.datacite.org/dois/10.23676/2j0v-ft05" }
  let(:expected_post_uri) { "https://apitest:apitest@api.test.datacite.org/dois/10.23676/2j0v-ft05" }

  before do
    allow(Hydra::RemoteIdentifier).to receive(:remote_service).and_return(doi_remote_service)
  end

  describe "#perform" do
    it "calls RestClient with the correct params" do
      VCR.use_cassette "remotely_identified_doi_embargo_update_work", record: :new_episodes do
        expect(RestClient).to receive(:put).with(
          expected_post_uri,
          "{\n  \"data\": {\n    \"type\": \"dois\",\n    \"attributes\": {\n      \"event\": \"publish\"\n    }\n  }\n}",
          content_type: :json
        )

        described_class.perform_now(identifier_uri)
      end
    end
  end
end
