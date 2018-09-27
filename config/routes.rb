Rails.application.routes.draw do
  mount AhoyEmail::Engine => "/ahoy" if AhoyEmail.api
end

AhoyEmail::Engine.routes.draw do
  scope module: "ahoy" do
    resources :messages, only: [] do
      get :open, on: :member
      get :click, on: :member
    end
  end
end
