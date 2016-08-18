Rails.application.routes.draw do
  resources :workgroups
  devise_for :users

  root 'application#index'
end
