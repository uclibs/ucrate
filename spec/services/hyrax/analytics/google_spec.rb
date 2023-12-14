# frozen_string_literal: true
require 'rails_helper'
RSpec.describe Hyrax::Analytics::Google::Config do
  subject { described_class }
  let!(:response) { described_class.load_from_yaml }
  it 'defines analytics variables' do
    expect(response.app_name).to eq("GOOGLE_OAUTH_APP_NAME")
    expect(response.app_version).to eq("GOOGLE_OAUTH_APP_VERSION")
    expect(response.privkey_path).to eq("analytics_privkey_path")
    expect(response.privkey_secret).to eq("analytics_privkey_secret")
    expect(response.client_email).to eq("analytics_client_email")
  end
end
