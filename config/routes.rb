Rails.application.routes.draw do
  root to: 'static_pages#home'

  get :signup, to: 'users#new'
  get :signin, to: 'sessions#new'
  delete :signout, to: 'sessions#destroy'

  get :help, to: 'static_pages#help'
  get :about, to: 'static_pages#about'
  get :contact, to: 'static_pages#contact'

  resources :users do
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
  resources :sessions, only: [:new, :create, :destroy]
  resources :microposts, only: [:show, :create, :destroy] do
    resources :comments, only: [:create]
  end
  resources :comments, only: [:destroy] do
    resources :comments, only: [:create]
  end
  resources :relationships, only: [:create, :destroy]
end
