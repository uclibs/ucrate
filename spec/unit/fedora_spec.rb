# frozen_string_literal: true
require 'rails_helper'

describe ActiveFedora::Fedora do
  subject(:fedora) { described_class.new(config) }
  describe "#authorized_connection" do
    describe "with SSL options" do
      let(:config) do
        { url: "https://example.com",
          user: "fedoraAdmin",
          password: "fedoraAdmin",
          ssl: { ca_path: '/path/to/certs' } }
      end
      specify do
        expect(Faraday).to receive(:new).with("https://example.com", ssl: { ca_path: '/path/to/certs' }).and_call_original
        fedora.authorized_connection
      end
    end
    describe "with request options" do
      let(:config) do
        { url: "https://example.com",
          user: "fedoraAdmin",
          password: "fedoraAdmin",
          request: { timeout: 600, open_timeout: 60 } }
      end
      specify do
        expect(Faraday).to receive(:new).with("https://example.com", request: { timeout: 600, open_timeout: 60 }).and_call_original
        fedora.authorized_connection
      end
    end
  end
end
