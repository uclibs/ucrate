# frozen_string_literal: true

require 'sidekiq/web'
require 'sidekiq/api'
Rails.application.routes.draw do
  mount Orcid::Engine => "/orcid"
  mount Scholar::API => '/'

  scope :dashboard do
    resources :collection_exports, only: [:index, :create, :destroy]
    get '/collection_exports/:id/download', to: 'collection_exports#download', as: 'collection_export_download'
  end

  mount BrowseEverything::Engine => '/browse'
  mount Riiif::Engine => 'images', as: :riiif if Hyrax.config.iiif_image_server?
  mount Blacklight::Engine => '/'
  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
  end
  resource :featured_collection, only: [:create, :destroy]

  authenticate :user, ->(u) { u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  devise_for :users, controllers: { omniauth_callbacks: 'callbacks', registrations: "registrations" }
  mount Hydra::RoleManagement::Engine => '/'

  resources :users, only: [:index], constraints: { format: :html }, controller: 'display_users'

  get 'login' => 'static#login'
  get 'about' => 'static#about'
  get 'help' => 'static#help'
  get 'contact' => 'hyrax/contact_form#new'
  get 'coll_policy' => 'static#coll_policy'
  get 'format_advice' => 'static#format_advice'
  get 'faq' => 'static#faq'
  get 'documenting_data' => 'static#documenting_data'
  get 'creators_rights' => 'static#creators_rights'
  get 'student_work_help' => 'static#student_work_help'
  get 'advisor_guidelines' => 'static#advisor_guidelines'
  get 'student_instructions' => 'static#student_instructions'
  get 'doi_help' => 'static#doi_help'
  get 'distribution_license_request' => 'hyrax/static#agreement'
  get 'terms' => 'static#terms'
  get 'agreement' => 'hyrax/static#agreement'
  get 'whats_new' => 'static#whats_new'

  # route for custom error pages issue #1056
  match '/404', to: 'errors#not_found', via: :all
  match '/422', to: 'errors#unprocessable', via: :all
  match '/500', to: 'errors#server_error', via: :all

  mount Qa::Engine => '/authorities'
  mount Hyrax::Engine, at: '/'
  resources :welcome, only: 'index'
  resources :welcome_page, only: [:index, :create]
  root 'hyrax/homepage#index'
  curation_concerns_basic_routes
  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  resources :feed, only: 'index'
  get 'sitemap.xml' => 'sitemaps#index', format: 'xml', as: :sitemap

  match 'show/:id' => 'common_objects#show', via: :get, as: 'common_object'

  resources :classify_concerns, only: [:new, :create]

  # Routes for sidekiq monitoring
  match "queue-status" => proc {
    [200,
     { "Content-Type" => "text/plain" },
     [Sidekiq::Queue.new.size.to_s]]
  }, via: :get
  match "queue-latency" => proc {
    [200,
     { "Content-Type" => "text/plain" },
     [Sidekiq::Queue.new.latency.to_s]]
  }, via: :get

  resources :uploads, constraints: { format: :json }, controller: 'api_uploads_controller'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
