Rails.application.routes.draw do
  post '/callback' => 'scores#callback'
end
