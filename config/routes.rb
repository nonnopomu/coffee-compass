Rails.application.routes.draw do
  resources :cafes, only: [ :index, :show ] do
    resources :drink_logs, only: [ :new ]
  end

  resources :drink_logs, only: [ :new, :create, :show, :edit, :update, :destroy ]

  resources :searches, only: [] do
    collection do
      get :area
      get :tag
    end
  end

  resource :mypage, only: [ :show ]

  namespace :admin do
    root "dashboards#show"

    resources :cafes, only: [ :index, :new, :create, :edit, :update ]
    resources :tags, only: [ :index, :new, :create, :edit, :update ]
  end

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  devise_for :users

  get "up" => "rails/health#show", as: :rails_health_check
  get "terms", to: "pages#terms"
  get "privacy", to: "pages#privacy"

  root "pages#top"
end
