Rails.application.routes.draw do
  root to: "sites#index"

  devise_for :users, controllers: { registrations: "users/registrations" }

  resources :users, only: %i[index show edit update destroy] do
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

  resources :relationships, only: %i[create destroy]

  resources :posts, except: %i[index] do
    resources :comments, except: %i[index show]
    member do
      get :large_image
    end
  end

  resources :events do
    resources :invitations, only: %i[create update]
    resources :comments, except: %i[index show]
    member do
      get :remove_image
    end
    collection do
      get :calendar
    end
  end

  resource :notifications, only: %i[show edit update], path_names: { edit: "settings" } do
    patch :mark_all_as_read
  end

  resources :likes, only: %i[create destroy] do
    collection do
      get :who
    end
  end

  resources :reposts, only: %i[create destroy] do
    collection do
      get :who
      get :select
    end
  end

  resource :timezones, only: %i[edit update]

  resources :bug_reports

  resources :infinite_scroll, only: %i[index]

  get "set_theme", to: "theme#update"

  resources :directs, path: "direct_messages" do
    resources :messages, except: %i[index]
    collection do
      get "user/:user_id", as: :personal, to: "directs#personal"
    end
  end

  get "sitemap.xml", to: "sites#sitemap", format: :xml
  get :privacy_policy, to: "sites#privacy_policy"

  # PWA files
  get "manifest.json", to: redirect("/manifest.json")
  get "service-worker.js", to: redirect("/service-worker.js")
end
