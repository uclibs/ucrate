# frozen_string_literal: true
require 'rails_helper'

describe ProxyEditRemovalJob do
  let!(:current_user) { create(:user) }
  let!(:proxy) { create(:user) }

  let!(:work) { FactoryBot.build(:generic_work, user: proxy, depositor: current_user.email, edit_users: [current_user, proxy], proxy_depositor: proxy.email, on_behalf_of: current_user.email) }
  let!(:file_set) { FactoryBot.build(:file_set, user: proxy, depositor: current_user.email, edit_users: [current_user, proxy], title: ['ABC123xyz']) }

  before do
    work.ordered_members << file_set
    work.save!
  end

  it "removes proxy user as an editor" do
    expect(file_set.edit_users).to include proxy.email
    described_class.perform_now(current_user, proxy)
    work.reload
    file_set.reload
    expect(work.edit_users).not_to include proxy.email
    expect(file_set.edit_users).not_to include proxy.email
  end
end
