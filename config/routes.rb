Rails.application.routes.draw do
  mount AhoyEmail::Engine => "/ahoy"
end

AhoyEmail::Engine.routes.draw do
  scope module: "ahoy" do
    resources :messages, only: [] do
      get :open, on: :collection
      get :click, on: :collection
    end
  end
end
