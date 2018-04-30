require 'sidekiq/web'
Rails.application.routes.draw do
  resources :collection_exports, only: [:index, :create, :destroy]
  get '/collection_exports/:id/download', to: 'collection_exports#download', as: 'collection_export_download'

  mount BrowseEverything::Engine => '/browse'
  mount Riiif::Engine => 'images', as: :riiif if Hyrax.config.iiif_image_server?
  mount Blacklight::Engine => '/'
  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
  end

  authenticate :user, ->(u) { u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  devise_for :users, controllers: { omniauth_callbacks: 'callbacks' }
  mount Hydra::RoleManagement::Engine => '/'

  get 'login' => 'static#login'

  mount Qa::Engine => '/authorities'
  mount Hyrax::Engine, at: '/'
  resources :welcome, only: 'index'
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

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
