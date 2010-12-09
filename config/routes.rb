ActionController::Routing::Routes.draw do |map|

  map.resources :data_responses, :member => { :review => :get, :submit => :put}

  map.data_requests 'data_requests', :controller => 'data_requests', :action => :index #until we flesh out this model

  # routes for CSV uploading for various models
  %w[activities funding_flows projects providers funding_sources model_helps comments other_costs organizations users sub_activities].each do |model|
    map.create_from_file model+"/create_from_file", :controller => model, :action => "create_from_file"
    map.create_from_file_form model+"/create_from_file_form", :controller => model, :action => "create_from_file_form"
  end

  map.funding_sources_data_entry "funding_sources",
    :controller => 'funding_sources', :action => 'index'

  map.providers_data_entry "providers",
      :controller => 'providers', :action => 'index'

  map.resources :projects,
    :collection => {:browse => :get},
    :member => {:select => :post}, :active_scaffold => true

  map.resources :organizations,
      :collection => {:browse => :get},
      :member => {:select => :post}, :active_scaffold => true


  map.resources :activities,
                :member => {:approve => :put,
                            :use_budget_codings_for_spend => :put,
                            :classifications => :get},
                :active_scaffold => true          do |activity|

    map.resources :classifications, :member => {:popup_classification => :get }, :active_scaffold => true
    activity.resource :coding, :controller => :code_assignments,
                               :only => [:show, :update],
                               :member => {:copy_budget_to_spend => :put}
    map.resources :sub_activities, :active_scaffold => true
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

  #reports
  map.activities_by_district 'activities_by_district', :controller => 'reports', :action => 'activities_by_district'
  map.activities_by_district_sub_activities 'activities_by_district_sub_activities', :controller => 'reports', :action => 'activities_by_district_sub_activities'
  map.activities_by_budget_coding 'activities_by_budget_coding', :controller => 'reports', :action => 'activities_by_budget_coding'
  map.activities_by_budget_cost_cat 'activities_by_budget_cost_cat', :controller => 'reports', :action => 'activities_by_budget_cost_cat'
  map.activities_by_budget_districts 'activities_by_budget_districts', :controller => 'reports', :action => 'activities_by_budget_districts'
  map.activities_by_expenditure_coding 'activities_by_expenditure_coding', :controller => 'reports', :action => 'activities_by_expenditure_coding'
  map.activities_by_expenditure_cost_cat 'activities_by_expenditure_cost_cat', :controller => 'reports', :action => 'activities_by_expenditure_cost_cat'
  map.activities_by_expenditure_districts 'activities_by_expenditure_districts', :controller => 'reports', :action => 'activities_by_expenditure_districts'
  map.activity_report 'activity_report', :controller => 'reports', :action => 'activity_report'
  map.activities_by_district_new 'activities_by_district_new', :controller => 'reports', :action => 'activities_by_district_new'
  map.activities_by_budget_coding_new 'activities_by_budget_coding_new', :controller => 'reports', :action => 'activities_by_budget_coding_new'
  map.activities_by_district_row_report 'activities_by_district_row_report', :controller => 'reports', :action => 'activities_by_district_row_report'
  map.activities_by_budget_stratprog 'activities_by_budget_stratprog', :controller => 'reports', :action => 'activities_by_budget_stratprog'
  map.activities_by_nsp 'activities_by_nsp/:id/:type',
                    :controller => 'reports',
                    :action => 'activities_by_nsp',
                    :type => Regexp.new(ReportsController::TYPE_MAP.keys.join('|'))
  map.activities_by_full_coding 'activities_by_full_coding/:id/:type',
                    :controller => 'reports',
                    :action => 'activities_by_full_coding',
                    :type => Regexp.new(ReportsController::TYPE_MAP.keys.join('|'))
  map.districts_by_nsp 'districts_by_nsp/:id/:type',
                    :controller => 'reports',
                    :action => 'districts_by_nsp',
                    :type => Regexp.new(ReportsController::TYPE_MAP.keys.join('|'))
  map.districts_by_full_coding 'districts_by_full_coding/:id/:type',
                    :controller => 'reports',
                    :action => 'districts_by_full_coding',
                    :type => Regexp.new(ReportsController::TYPE_MAP.keys.join('|'))
  map.map_districts_by_nsp 'map_districts_by_nsp/:id/:type',
                    :controller => 'reports',
                    :action => 'map_districts_by_nsp',
                    :type => Regexp.new(ReportsController::TYPE_MAP.keys.join('|'))
  map.map_districts_by_full_coding 'map_districts_by_full_coding/:id/:type',
                    :controller => 'reports',
                    :action => 'map_districts_by_full_coding',
                    :type => Regexp.new(ReportsController::TYPE_MAP.keys.join('|'))
  map.map_districts_by_partner 'map_districts_by_partner/:type',
                    :controller => 'reports',
                    :action => 'map_districts_by_partner'
  map.map_facilities_by_partner 'map_facilities_by_partner/:type',
                    :controller => 'reports',
                    :action => 'map_facilities_by_partner'
  map.users_by_organization 'users_by_organization', :controller => 'reports', :action => 'users_by_organization'
  map.all_codes 'all_report', :controller => 'reports', :action => 'all_codes'
  map.users_in_my_organization 'users_in_my_organization', :controller => 'reports', :action => 'users_in_my_organization'

  # these routes make the pages accessible without security checks
  #TODO - this doesnt belong here. Must be moved to the controller - GR
  %w[about news contact submit].each do |p|
    map.send(p.to_sym, p, :controller => 'static_page', :action => p)
  end

  map.static_page ':page',
                  :controller => 'static_page',
                  :action => 'show',
                  :page => Regexp.new(%w[about contact about news submit user_guide reports].join('|'))

  map.root :controller => 'static_page', :action => 'index' # a replacement for public/index.html

  map.namespace :admin do |admin|
    admin.resources :data_responses, :member => {:delete => :get}
    admin.dashboard 'dashboard', :controller => 'dashboard', :action => :index
    admin.resources :organizations, :collection => {:duplicate => :get, :remove_duplicate => :put}
  end

  map.namespace :policy_maker do |policy_maker|
    policy_maker.resources :data_responses, :only => [:show, :index]
  end

  map.namespace :reporter do |reporter|
    reporter.dashboard 'dashboard', :controller => 'dashboard', :action => :index
    reporter.reports 'reports', :controller => 'dashboard', :action => :reports
    reporter.resources :data_responses, :only => [:show]
    reporter.resources :comments, :member => {:delete => :get}
  end

  map.charts 'charts/:action', :controller => 'charts'
end
