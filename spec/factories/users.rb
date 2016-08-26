FactoryGirl.define do
  factory :user, class: 'User' do
    email 'fake.user@uc.edu'
    first_name 'Johnny'
    last_name 'Appleseed'
    password '12345678'
    password_confirmation '12345678'
  end
end
