Rails.application.routes.draw do
  mount AhoyEmail::Engine => "/ahoy"
end

AhoyEmail::Engine.routes.draw do
  resources :messages, only: [] do
    get :open, on: :collection
  end
end
