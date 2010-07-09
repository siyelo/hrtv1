ActionController::Routing::Routes.draw do |map|

  map.data_requests 'data_requests', :controller => 'data_requests', :action => :index #until we flesh out this model

  map.funding_sources_data_entry "funding_sources", :controller => 'funding_sources', :action => 'index'
  map.providers_data_entry "providers", :controller => 'providers', :action => 'index'
  %w[activities funding_flows projects providers funding_sources].each do |model|
    map.create_from_file model+"/create_from_file", :controller => model, :action => "create_from_file"
  end

  map.resources :activities, :active_scaffold => true
  map.resources :indicators, :active_scaffold => true
  map.resources :line_items, :active_scaffold => true
  map.resources :projects, :active_scaffold => true
  map.resources :comments, :active_scaffold => true
  map.resources :field_helps, :active_scaffold => true
  map.resources :model_helps, :active_scaffold => true
  map.resources :organizations, :collection => {:browse => :get}, :active_scaffold => true
  map.resources :funding_flows, :active_scaffold => true
  map.resources :providers, :active_scaffold => true
  map.resources :codes, :active_scaffold => true

  map.resources :code_assignments, :only => [:index]
  map.manage_code_assignments 'manage_code_assignments', :controller => 'code_assignments', :action => :manage

  map.page_comments "page_comments/:id", :controller => 'comments', :action => 'index', :type => 'ModelHelp'

  # DRY up the static page controller
  map.static_page ':page',
                  :controller => 'static_page',
                  :action => 'show',
                  :page => Regexp.new(%w[about contact ngo_dashboard govt_dashboard admin_dashboard].join('|'))

  map.root :controller => 'static_page', :action => 'index' # a replacement for public/index.html

  #TODO remove these
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

end
