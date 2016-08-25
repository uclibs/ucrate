FactoryGirl.define do
  factory :workgroup do
    title "Workgroup"
    description "My Cool Workgroup"
    created_at Time.zone.today
    updated_at Time.zone.today
  end
end
