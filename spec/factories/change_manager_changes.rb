# frozen_string_literal: true
FactoryBot.define do
  factory :change, class: 'ChangeManager::Change' do
    owner "email@test.com"
    change_type "added_as_delegate"
    context "1"
    target "spec@test.com"
    cancelled false
    notified nil
  end
end
