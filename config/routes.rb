Rails.application.routes.draw do
  root to: 'sites#index'

  devise_for :users

  resources :users, only: [:index, :show, :edit, :update, :destroy] do
    member do
      get :remove_avatar
      patch :add_admin
      patch :remove_admin
      get :photos
      get :resume
    end
    collection do
      get :search
      get :admins
    end
  end

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

  resources :companies, param: :company_id do
    collection do
      get :search, as: :search_industries
    end
    member do
      get :remove_logo
    end
  end

  resource :notifications, only: [:show, :edit, :update], path_names: { edit: 'settings' } do
    patch :mark_all_as_read
  end

  resource :history, only: [:show, :edit, :update] do
    get 'remove_image/:image_id', as: :remove_image, to: 'histories#remove_image'
  end

  resources :past_presidents, except: [:index]

  resource :timezones, only: [:edit, :update]

  resources :news_letters, except: [:new] do
    resources :articles, except: [:index]
    member do
      patch :publish
      patch :un_publish
    end
  end

  resources :additional_recipients, except: [:show]

  resources :resumes, except: [:show]

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
