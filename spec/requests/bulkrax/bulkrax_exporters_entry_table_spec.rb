# spec/requests/bulkrax/exporters_entry_table_spec.rb
require 'rails_helper'

RSpec.describe 'Bulkrax exporter entry_table', type: :request do
  include Devise::Test::IntegrationHelpers
  include Warden::Test::Helpers

  before { Warden.test_mode! }
  after  { Warden.test_reset! }

  it 'returns JSON (even with no entries) for an admin user' do
    user = User.find_by(email: 'spec-admin@example.com') ||
           User.create!(email: 'spec-admin@example.com', password: 'password123')

    # grant admin
    role = Role.find_or_create_by!(name: 'admin')
    role.users << user unless role.users.include?(user)

    exporter = Bulkrax::Exporter.create!(
      name: 'Test Exporter',
      user: user,
      parser_klass: 'Bulkrax::CsvParser',
      export_type: 'metadata',
      export_from: 'worktype',
      export_source: 'GenericWork', # change if your work class differs
      generated_metadata: false,
      include_thumbnails: false
    )

    sign_in user
    login_as(user, scope: :user)

    # Route helper can differ by mount/engine; the raw path is stable in your app:
    get "/exporters/#{exporter.id}/entry_table.json"

    expect(response).to have_http_status(:ok).or have_http_status(:no_content)
    JSON.parse(response.body) if response.body.present?
  end
end
