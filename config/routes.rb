Rails.application.routes.draw do
  root to: "sites#index"

  devise_for :users, controllers: { registrations: "users/registrations" }

  resources :users, only: [ :index, :show, :edit, :update, :destroy ] do
    member do
      get :remove_avatar
      patch :add_admin
      patch :remove_admin
      get :media
      get :followers
      get :following
    end
    collection do
      get :search
      get :site_admins
    end
  end

  resources :relationships, only: [ :create, :destroy ]

  resources :posts, except: [ :index ] do
    resources :comments, except: [ :index, :show ]
    member do
      get :close_modal
    end
  end

  resources :events do
    resources :invitations, only: [ :create, :update ]
    resources :comments, except: [ :index, :show ]
    member do
      get :remove_image
    end
    collection do
      get :calendar
    end
  end

  resource :notifications, only: [ :show, :edit, :update ], path_names: { edit: "settings" } do
    patch :mark_all_as_read
  end

  resources :likes, only: [ :create, :destroy ] do
    collection do
      get :who
    end
  end

  resources :reposts, only: [ :create, :destroy ] do
    collection do
      get :who
      get :select
    end
  end

  resource :timezones, only: [ :edit, :update ]

  resources :bug_reports

  resources :infinate_scroll, only: [ :index ]

  get "set_theme", to: "theme#update"

  resources :directs, path: "direct_messages" do
    resources :messages, except: [ :index ]
    collection do
      get "user/:user_id", as: :personal, to: "directs#personal"
    end
  end

  get "sitemap.xml", to: "sites#sitemap", format: :xml
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
