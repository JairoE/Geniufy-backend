Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users , only: [:index, :create, :show] do
        resources :favorites, only: [:index, :create, :show]
        resources :follows, only: [:index, :create, :show]
      end
      resources :songs, only: [:index, :create, :show, :update] do
        resources :annotations, only: [:index, :create, :show]
      end

      post '/fetchSongs', to: 'songs#fetchSongs'
      get '/login', to: 'users#login'
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
