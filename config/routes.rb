Rails.application.routes.draw do
  # post '/callback' => 'scores#callback'
  post '/callback' => 'line_bot#callback'

  resources :scores, only: [:index, :edit, :update, :destroy]
  root to: "scores#index"
end
