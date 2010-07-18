ActionController::Routing::Routes.draw do |map|

  map.coding "activities/code", :controller => 'activities', :action => 'code'
  map.coding "activities/random", :controller => 'activities', :action => 'random'
  map.data_requests 'data_requests', :controller => 'data_requests', :action => :index #until we flesh out this model

  map.funding_sources_data_entry "funding_sources", :controller => 'funding_sources', :action => 'index'
  map.providers_data_entry "providers", :controller => 'providers', :action => 'index'
  %w[activities funding_flows projects providers funding_sources model_helps comments other_costs].each do |model|
    map.create_from_file model+"/create_from_file", :controller => model, :action => "create_from_file"
  end

  map.resources :projects,
    :collection => {:browse => :get},
    :member => {:select => :post}, :active_scaffold => true

  map.resources :organizations,
    :collection => {:browse => :get},
    :member => {:select => :post}, :active_scaffold => true

  map.resources :activities, :active_scaffold => true
  map.resources :indicators, :active_scaffold => true
  map.resources :line_items, :active_scaffold => true
  map.resources :comments, :active_scaffold => true
  map.resources :field_helps, :active_scaffold => true
  map.resources :model_helps, :active_scaffold => true
  map.resources :funding_flows, :active_scaffold => true
  map.resources :codes, :active_scaffold => true
  map.resources :activity_cost_categories, :active_scaffold => true
  map.resources :other_costs, :active_scaffold => true
  map.resources :other_cost_types, :active_scaffold => true

  map.resources :users, :active_scaffold => true

  map.resource :user_session
  map.login 'login', :controller => 'user_sessions', :action => 'new'
  map.logout 'logout', :controller => 'user_sessions', :action => 'destroy'

  map.resources :code_assignments, :only => [:index]
  map.manage_code_assignments 'manage_code_assignments/:activity_id', :controller => 'code_assignments', :action => :manage
  map.update_code_assignments 'update_code_assignments', :controller => 'code_assignments', :action => :update_assignments, :method => :post

  map.static_page ':page',
                  :controller => 'static_page',
                  :action => 'show',
                  :page => Regexp.new(%w[about contact ngo_dashboard govt_dashboard admin_dashboard].join('|'))

  map.root :controller => 'static_page', :action => 'index' # a replacement for public/index.html

  #TODO remove these
  #map.connect ':controller/:action/:id'
  #map.connect ':controller/:action/:id.:format'

end

