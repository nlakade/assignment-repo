Rails.application.routes.draw do
  resources :articles, only: [:index, :new, :create, :show] do
    collection do
      post :ai_generate
    end
  end
  
  get '/blog/:slug', to: 'articles#show', as: :article
  root 'articles#index'
end