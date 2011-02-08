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

  map.resources :data_responses,
                  :member => {:review => :get,
                              :submit => :put}
  map.charts 'charts/:action', :controller => 'charts' # TODO: convert to resource

  # STATIC PAGES
  map.static_page ':page', :controller => 'static_page', :action => 'show',
                   :page => Regexp.new(%w[about contact news user_guide].join('|'))

  # ADMIN
  map.namespace :admin do |admin|
    admin.resources :responses,
                    :collection => {:empty => :get, :in_progress => :get, :submitted => :get},
                    :member     => {:delete => :get}
    admin.resources :organizations,
                    :collection => { :duplicate => :get, :remove_duplicate  => :put},
                    :active_scaffold => true
    admin.resources :reports
    admin.resources :users, :active_scaffold => true
    admin.resources :activities, :active_scaffold => true
    admin.dashboard 'dashboard', :controller => 'dashboard', :action => :index
  end

  # POLICY MAKER
  map.namespace :policy_maker do |policy_maker|
    policy_maker.resources :data_responses, :only => [:show, :index]
  end

  # REPORTER
  map.namespace :reporter do |reporter|
    reporter.dashboard 'dashboard', :controller => 'dashboard', :action => :index
    reporter.resources :data_responses, :only => [:show]
    reporter.resources :reports, :only => [:index, :show]
    reporter.resources :comments, :member => {:delete => :get}
  end

  # REPORTS
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
  %w[activities funding_flows projects funding_sources implementers model_helps comments other_costs organizations users sub_activities].each do |model|
    map.create_from_file model + "/create_from_file", :controller => model, :action => "create_from_file"
    map.create_from_file_form model + "/create_from_file_form", :controller => model, :action => "create_from_file_form"
  end
  map.resources :funding_sources, :only => [:index]
  map.resources :implementers, :only => [:index]
  map.resources :projects,
                :collection => {:browse => :get},
                :member => {:select => :post},
                :active_scaffold => true
  map.resources :organizations,
                :collection => {:browse => :get},
                :member => {:select => :post},
                :active_scaffold => true
  map.resources :activities,
                :member => {:approve => :put, :classifications => :get},
                :active_scaffold => true do |activity|
                activity.resource :code_assignments, :only => [:show, :update],
                                  :member => {:copy_budget_to_spend => :put}
  end
  map.resources :classifications,
                :member => {:popup_classification => :get},
                :active_scaffold => true
  map.resources :sub_activities, :active_scaffold => true
  map.resources :comments,        :active_scaffold => true
  map.resources :field_helps,     :active_scaffold => true
  map.resources :model_helps,     :active_scaffold => true
  map.resources :funding_flows,   :active_scaffold => true
  map.resources :codes,           :active_scaffold => true
  map.resources :other_costs,
                :member => {:popup_classification => :get},
                :active_scaffold => true
  #map.popup_other_cost_coding "popup_other_cost_coding", :controller => 'other_costs', :action => 'popup_coding'
  map.resources :users,           :active_scaffold => true
  map.resources :help_requests,   :active_scaffold => true
end
