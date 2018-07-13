# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'hide share group feature', :js, :workflow do # snake-case work type for string interpolation
  let(:user) { create(:user) }
  let(:admin_set) { create(:admin_set) }
  let(:permission_template) { create(:permission_template, source_id: admin_set.id) }
  let!(:workflow) { create(:workflow, allows_access_grant: true, active: true, permission_template_id: permission_template.id) }

  before do
    create(:permission_template_access,
           :deposit,
           permission_template: create(:permission_template, with_admin_set: true, with_active_workflow: true),
           agent_type: 'user',
           agent_id: user.user_key)

    sign_in user
    visit '/concern/generic_works/new#share'
  end

  it 'does not display group share feature' do
    expect(page).not_to have_content('Add group')
  end
end
