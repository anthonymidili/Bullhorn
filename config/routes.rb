Rails.application.routes.draw do
  root to: 'sites#index'

  devise_for :users

  resources :users, only: [:index, :show, :edit, :update, :destroy] do
    member do
      get :remove_avatar
      patch :add_admin
      patch :remove_admin
      get :photos
      get :followers
      get :following
    end
    collection do
      get :search
      get :site_admins
    end
  end

  resources :relationships, only: [:create, :destroy]

  resources :posts, except: [:index] do
    resources :comments, except: [:index, :show]
  end

  resources :events do
    resources :invitations, only: [:create, :update]
    resources :comments, except: [:index, :show]
    member do
      get :remove_image
    end
    collection do
      get :calendar
    end
  end

  resource :notifications, only: [:show, :edit, :update], path_names: { edit: 'settings' } do
    patch :mark_all_as_read
    get "/:id/new_frame", as: :new_frame, to: "notifications#new_frame"
  end

  resources :likes, only: [:create, :destroy] do
    collection do
      get :who
    end
  end

  resource :timezones, only: [:edit, :update]

  resources :bug_reports

  resources :infinate_scroll, only: [:index]

  get 'set_theme', to: 'theme#update'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
