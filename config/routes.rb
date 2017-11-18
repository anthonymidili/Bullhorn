Rails.application.routes.draw do
  root to: 'static_pages#home'

  devise_for :users

  get :help, to: 'static_pages#help'
  get :about, to: 'static_pages#about'
  get :contact, to: 'static_pages#contact'

  resources :users, except: [:new, :create, :edit, :update] do
    member do
      get :following, :followers
    end
    resources :photos, path_names: { new: 'upload' } do
      member do
        patch :update_avatar
        get :full_size
      end
      collection do
        put :presign_upload
      end
    end
    collection do
      get :search
    end
  end
  resources :microposts, only: [:show, :create, :destroy] do
    resources :comments, only: [:create]
  end
  resources :comments, only: [:destroy] do
    resources :comments, only: [:create]
  end
  resources :relationships, only: [:create, :destroy]
end
