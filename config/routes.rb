ActionController::Routing::Routes.draw do |map|
  map.resources :data_responses, :member => { :review => :get, :submit => :put}

  map.data_requests 'data_requests', :controller => 'data_requests', :action => :index #until we flesh out this model

  # routes for CSV uploading for various models
  %w[activities funding_flows projects providers funding_sources model_helps comments other_costs organizations users sub_activities].each do |model|
    map.create_from_file model + "/create_from_file", :controller => model, :action => "create_from_file"
    map.create_from_file_form model + "/create_from_file_form", :controller => model, :action => "create_from_file_form"
  end

  map.funding_sources_data_entry "funding_sources",
    :controller => 'funding_sources', :action => 'index'

  map.providers_data_entry "providers",
      :controller => 'providers', :action => 'index'

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
    map.resources :classifications,
                  :member => {:popup_classification => :get },
                  :active_scaffold => true
    activity.resource :coding,
                      :controller => :code_assignments,
                      :only => [:show, :update],
                      :member => {:copy_budget_to_spend => :put}
    map.resources :sub_activities,
                  :active_scaffold => true
  end

  map.popup_other_cost_coding "popup_other_cost_coding", :controller => 'other_costs', :action => 'popup_coding'

  map.resources :comments, :active_scaffold => true
  map.resources :field_helps, :active_scaffold => true
  map.resources :model_helps, :active_scaffold => true
  map.resources :funding_flows, :active_scaffold => true
  map.resources :codes, :active_scaffold => true
  map.resources :other_costs, :active_scaffold => true

  map.resources :users, :active_scaffold => true
  map.resource :user_session

  map.resources :help_requests, :active_scaffold => true

  map.login 'login', :controller => 'user_sessions', :action => 'new'
  map.logout 'logout', :controller => 'user_sessions', :action => 'destroy'

  # these routes make the pages accessible without security checks
  #TODO - this doesnt belong here. Must be moved to the controller - GR
  %w[about news contact submit].each do |p|
    map.send(p.to_sym, p, :controller => 'static_page', :action => p)
  end

  map.static_page ':page', :controller => 'static_page', :action => 'show',
                   :page => Regexp.new(%w[about contact about news submit user_guide].join('|'))

  map.root :controller => 'static_page', :action => 'index' # a replacement for public/index.html

  map.namespace :admin do |admin|
    admin.resources :responses,
                    :collection => {:empty => :get, :in_progress => :get, :submitted => :get},
                    :member     => {:delete => :get}
    admin.resources :organizations,
                    :collection => { :duplicate => :get, :remove_duplicate  => :put},
                    :active_scaffold => true
    admin.resources :reports, :only => [:index, :show]
    admin.resources :users, :active_scaffold => true
    admin.resources :activities, :active_scaffold => true
    admin.dashboard 'dashboard', :controller => 'dashboard', :action => :index
  end

  map.namespace :reports do |reports|
    reports.resources :districts, :only => [:index, :show] do |districts|
      districts.resources :activities, :only => [:index, :show], :controller => "districts/activities"
      districts.resources :organizations, :only => [:index, :show], :controller => "districts/organizations"
    end
    reports.resource :country do |country|
      country.resources :activities, :only => [:index, :show], :controller => "countries/activities"
      country.resources :organizations, :only => [:index, :show], :controller => "countries/organizations"
    end
  end

  map.namespace :policy_maker do |policy_maker|
    policy_maker.resources :data_responses, :only => [:show, :index]
  end

  map.namespace :reporter do |reporter|
    reporter.dashboard 'dashboard', :controller => 'dashboard', :action => :index
    reporter.resources :data_responses, :only => [:show]
    reporter.resources :reports, :only => [:index, :show]
    reporter.resources :comments, :member => {:delete => :get}
  end

  map.charts 'charts/:action', :controller => 'charts'
end
