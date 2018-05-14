Rails.application.routes.draw do
  resources :annotation_threads
  namespace :api do
    namespace :v1 do
      resources :users , only: [:index, :create, :show] do
        resources :favorites, only: [:index, :create, :show]
      end
      resources :songs, only: [:index, :create, :show, :update] do
        resources :annotations, only: [:index, :create, :show] do
          post '/chainAnnotation', to: 'annotations#chainAnnotation'
        end
      end

      post '/fetchSongs', to: 'songs#fetchSongs'
      get '/login', to: 'users#login'
      post '/postLogin', to: 'users#postLogin'
      post '/getPlaylists', to: 'playlists#getPlaylists'
      post '/getPlaylistTracks', to: 'playlists#getPlaylistTracks'
      post '/playTrack', to: 'playlists#playTrack'
      post '/playSong', to: 'songs#playSong'
      post '/play', to: 'playlists#play'
      post '/pause', to: 'playlists#pause'
      post '/previous', to: 'playlists#previous'
      post '/next', to: 'playlists#next'
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
