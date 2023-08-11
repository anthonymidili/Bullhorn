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
  end

  resources :likes, only: [:create, :destroy]

  resource :timezones, only: [:edit, :update]

  resources :bug_reports

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
