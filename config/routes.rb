require 'sidekiq/web'

Rails.application.routes.draw do
  root to: 'home#index'
  
  devise_for :admins, skip: :registrations

  namespace :admin, authenticate: :admin do
    mount Sidekiq::Web => '/sidekiq'
  end                                  

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  devise_for :users, controllers: { registrations: 'registrations',
                                    omniauth_callbacks: 'omniauth_callbacks' }


  resources :f, only: [ :index ]

  namespace :a, constraints: { format: :json }, defaults: { format: :json } do
    namespace :v1 do
      resources :users, only: [ :show ] do
        collection do
          get ':id/faves', to: 'users#faves'
        end
      end
      resources :profile, only: [ :index, :create ]
      resources :top_articles, only: [ :index ]
      resources :master_feeds, only: [ :index ]
      resources :search, only: [ :index ]
      resources :fave, only: [ :index ]

      resources :sessions, only: [] do
        collection do
          get 'facebook'
        end
      end
      resources :registrations, only: [] do
        collection do
          post 'facebook'
        end
      end
    end
  end


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
