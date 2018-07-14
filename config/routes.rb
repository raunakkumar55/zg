Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'urls/new' => 'urls#new'
  post 'urls/shorten' => 'urls#shorten'
  get 'urls' => 'urls#index'

  get '/(:short_token)' => 'urls#inflate'
end
