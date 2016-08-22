FactoryGirl.define do
  factory :workgroup_membership do
    user_id "1"
    workgroup_id "1"
    workgroup_role_id "1"
    created_at Date.today
    updated_at Date.today
  end
end
