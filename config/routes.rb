ActionController::Routing::Routes.draw do |map|
  # ROOT
  map.root :controller => 'static_page', :action => 'index'

  # LOGIN/LOGOUT
  map.resource  :user_session
  map.login     'login', :controller => 'user_sessions', :action => 'new'
  map.logout    'logout', :controller => 'user_sessions', :action => 'destroy'
  map.resources :password_resets

  # PROFILE
  map.resource :profile, :only => [:edit, :update]

  # STATIC PAGES
  map.about_page 'about', :controller => 'static_page',
    :action => 'about'

  # ADMIN
  map.namespace :admin do |admin|
    admin.resources :requests
    admin.resources :responses,
      :collection => {:empty => :get, :in_progress => :get, :submitted => :get},
      :member     => {:delete => :get}
    admin.resources :organizations,
      :collection => { :duplicate => :get, :remove_duplicate  => :put}
    admin.resources :reports, :member => {:generate => :get}
    admin.resources :users,
      :collection => {:create_from_file => :post, :download_template => :get}
    admin.resources :activities, :active_scaffold => true
    admin.dashboard 'dashboard', :controller => 'dashboard', :action => :index
  end

  # POLICY MAKER
  map.namespace :policy_maker do |policy_maker|
    policy_maker.resources :responses, :only => [:show, :index]
  end

  # REPORTER USER: DATA ENTRY
  map.resources :responses,
    :member => {:review => :get, :submit => :put} do |response|
      response.resources :projects,
        :collection => {:create_from_file => :post, :download_template => :get}
      response.resources :activities,
        :member => {:approve => :put, :classifications => :get},
        :collection => {:create_from_file => :post, :download_template => :get,
                        :project_sub_form => :get}
      response.resources :other_costs,
        :collection => {:create_from_file => :post, :download_template => :get}
  end

  map.resources :activities do |activity|
    activity.resource :code_assignments,
      :only => [:show, :update],
      :member => {:copy_budget_to_spend => :put,
      :derive_classifications_from_sub_implementers => :put}
  end

  # REPORTER USER
  map.namespace :reporter do |reporter|
    reporter.dashboard 'dashboard', :controller => 'dashboard', :action => :index
    reporter.resources :responses, :only => [:show]
    reporter.resources :reports, :only => [:index, :show]
    reporter.resources :comments, :member => {:delete => :get}
  end

  # REPORTS
  map.charts 'charts/:action', :controller => 'charts' # TODO: convert to resource

  map.namespace :reports do |reports|
    reports.resources :districts, :only => [:index, :show] do |districts|
      districts.resources :activities, :only => [:index, :show],
        :controller => "districts/activities"
      districts.resources :organizations, :only => [:index, :show],
        :controller => "districts/organizations"
    end
    reports.resource :country do |country|
      country.resources :activities, :only => [:index, :show],
        :controller => "countries/activities"
      country.resources :organizations, :only => [:index, :show],
        :controller => "countries/organizations"
    end
  end

  # ACTIVE SCAFFOLD
  # routes for CSV uploading for various models
  %w[model_helps comments].each do |model|
    map.create_from_file model + "/create_from_file", :controller => model, :action => "create_from_file"
    map.create_from_file_form model + "/create_from_file_form", :controller => model, :action => "create_from_file_form"
  end

  # dont need to nest activities under response - can derive response_id from activity
  map.resources :comments,        :active_scaffold => true
  map.resources :field_helps,     :active_scaffold => true
  map.resources :model_helps,     :active_scaffold => true
  map.resources :codes,           :active_scaffold => true
  map.resources :help_requests,   :active_scaffold => true
end
