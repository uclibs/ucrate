Rails.application.routes.draw do
  resources :workgroups
  devise_for :users, :controllers => { registrations: 'users' }

  root 'application#index'
end
