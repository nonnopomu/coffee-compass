Rails.application.routes.draw do
  resources :cafes, only: [ :index, :show ] do
    collection do
      get :search_suggestions, to: "cafe_search_suggestions#index"
    end

    resources :drink_logs, only: [ :new ]
  end

  resources :drink_logs, only: [ :new, :create, :show, :edit, :update, :destroy ]

  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks",
    registrations: "users/registrations"
  }

  resource :mypage, only: [ :show ]
  resource :profile, only: [ :edit, :update ]
  resources :users, only: [ :show ]

  namespace :admin do
    root "dashboards#show"

    resources :cafes, only: [ :index, :new, :create, :edit, :update ]
    resources :tags, only: [ :index, :new, :create, :edit, :update ]
  end

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  get "up" => "rails/health#show", as: :rails_health_check
  get "terms", to: "pages#terms"
  get "privacy", to: "pages#privacy"

  root "pages#top"
end
