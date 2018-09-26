Rails.application.routes.draw do
  # unless respond_to?(:has_named_route?) && has_named_route?("ahoy_email_engine")
  #   mount AhoyEmail::Engine => "/ahoy"
  # end
end

AhoyEmail::Engine.routes.draw do
  scope module: "ahoy" do
    resources :messages, only: [] do
      get :open, on: :member
      get :click, on: :member
    end
  end
end
