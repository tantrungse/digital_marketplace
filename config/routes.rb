Rails.application.routes.draw do
  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    registration: 'signup'
  },
  controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  match '*path', via: [:options], to: -> (env) { [204, {}, ['']] }

  namespace :api do
    namespace :v1 do
      namespace :buyer do
        get 'spending', to: 'spend#index'
        resources :products do
          collection do
            get :browse
          end
        end
      end
    end
  end
end
