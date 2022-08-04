Spree::Core::Engine.add_routes do
  namespace :admin do
    resource :atlassian_settings, only: %i[edit update]
    resource :atlassian_ping, only: :create

    resources :users do
      member do
        get :atlassian_information
        put :atlassian_information
      end
    end

    resources :atlassian_entity_use_codes, except: :show
  end
end
