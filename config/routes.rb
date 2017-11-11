Rails.application.routes.draw do
  root to: 'bookmarks#index'
  resources :bookmarks
  resources :charges
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
