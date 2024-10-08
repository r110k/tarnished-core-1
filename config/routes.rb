Rails.application.routes.draw do

  get '/', to: 'home#index'

  namespace :api do
    namespace :v1 do
      resources :validation_codes, only: [:create]
      resource :session, only: [:create, :destroy]
      resource :me, only: [:show]
      resources :items do
        collection do
          get :summary
          get :balance
        end
      end
      resources :tags
    end
  end

end
