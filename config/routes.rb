Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :v1 do
    get "gender", to: "users#gender"
    get "birthdate", to: "users#birthdate"
    get "description", to: "users#description"

    post "gender", to: "users#update_gender"
    post "birthdate", to: "users#update_birthdate"
    post "description", to: "users#update_description"

    resources :users, only: [ :show ] do
      collection do
        get "authenticated", to: "users#authenticated"
        get "authenticated/roles", to: "users#authenticated_roles"
        get "authenticated/age-bracket", to: "users#authenticated_age_bracket"
        get "authenticated/country-code", to: "users#authenticated_country_code"
      end

      member do
        get "username-history", to: "users#username_history"
      end
    end
  end

  namespace :v2 do
    post "login", to: "auth#login"
    post "signup", to: "auth#signup"
  end

  # Defines the root path route ("/")
  # root "posts#index"
end
