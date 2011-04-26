ResourceTracking::Application.routes.draw do
  # ROOT
  match '/' => 'static_page#index'

  # LOGIN/LOGOUT
  resource :user_session
  match 'login' => 'user_sessions#new', :as => :login
  match 'logout' => 'user_sessions#destroy', :as => :logout
  resources :password_resets

  # PROFILE
  resource :profile, :only => [:edit, :update, :disable_tips] do
    member do
      put :disable_tips
    end
  end

  # STATIC PAGES
  match 'about' => 'static_page#about', :as => :about_page

  resources :comments do
    member do
      get :delete
    end
  end


  # ADMIN
  namespace :admin do
    resources :requests
    resources :responses do
      collection do
        get :in_progress
        get :submitted
        get :empty
      end
      member do
        get :delete
      end
    end
    resources :organizations do
      collection do
        get :download_template
        post :create_from_file
        get :duplicate
        put :remove_duplicate
      end
    end
    resources :reports do
      member do
        get :generate
      end
    end
    resources :users do
      collection do
        get :download_template
        post :create_from_file
      end
    end
    resources :activities
    resources :codes do
      collection do
        get :download_template
        post :create_from_file
      end
    end
    match 'dashboard' => 'dashboard#index', :as => :dashboard
  end

  # POLICY MAKER
  namespace :policy_maker do
    resources :responses, :only => [:show, :index]
  end

  # REPORTER USER: DATA ENTRY
  resources :responses do
    resources :commodities do
      collection do
        get :download_template
        post :create_from_file
      end
    end
    resources :projects do
      collection do
        get :download_template
        get :bulk_edit
        post :create_from_file
        put :bulk_update
      end
    end
    resources :activities do
      collection do
        get :download_template
        post :create_from_file
        get :project_sub_form
        put :bulk_create
      end
      member do
        put :approve
        get :classifications
      end

    end
    resources :other_costs do
      collection do
        get :download_template
        post :create_from_file
      end
    end
  end

  resources :activities do
    resource :code_assignments, :only => [:show, :update] do
      member do
        put :copy_budget_to_spend
        put :derive_classifications_from_sub_implementers
      end
    end
>>>>>>> Initial migration to rails3
  end

  # REPORTER USER
  namespace :reporter do
    match 'dashboard' => 'dashboard#index', :as => :dashboard
    resources :reports, :only => [:index, :show]
  end

  # REPORTS
  match 'charts/:action' => 'charts#index', :as => :charts

  namespace :reports do
    resources :districts do
      resources :activities, :only => [:index, :show]
      resources :organizations, :only => [:index, :show]
    end
    resource :country do
      resources :activities, :only => [:index, :show]
      resources :organizations, :only => [:index, :show]
    end
  end
end
