Rails.application.routes.draw do
  # post '/callback' => 'scores#callback'
  post '/callback' => 'line_bot#callback'
end
