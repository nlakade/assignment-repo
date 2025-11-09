Rails.application.routes.draw do
  resources :phone_calls, only: [:index, :create] do
    collection do
      post :start_calling
      post :ai_prompt
    end
  end
  
  root 'phone_calls#index'
end