Rails.application.routes.draw do

  namespace :api do
    namespace :v1 do
      resources :validation_codes, only: [:create]
      resource :session, only: [:create, :destroy]
      resource :me, only: [:show]
      resources :items
      resources :tags
    end
  end

end
