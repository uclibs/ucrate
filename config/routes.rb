Rails.application.routes.draw do
  resources :workgroup_memberships
  resources :workgroups
  devise_for :users

  root 'application#index'
end
