Rails.application.routes.draw do
  resources :cafes, only: [ :index ]

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  devise_for :users

  get "up" => "rails/health#show", as: :rails_health_check

  root "pages#top"
end
