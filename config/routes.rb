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
      get :photos, to: 'photos#view_photos', as: :photos
      get 'photos/:photo_id', to: 'photos#view_photo', as: :photo
      patch 'update_avatar/:photo_id', to: 'users#update_avatar', as: :update_avatar
    end
  end
  resources :sessions, only: [:new, :create, :destroy]
  resources :microposts, only: [:create, :destroy]
  resources :relationships, only: [:create, :destroy]
  resource :album, only: [:show, :edit, :update], path_names: { edit: 'upload' }
  resources :photos, only: [:show, :edit, :update, :destroy]
end
