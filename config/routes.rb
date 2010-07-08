ActionController::Routing::Routes.draw do |map|

  # GR - we'll namespace these as soon as the tests are running
  #map.namespace :ngo do |ngo|
  #  ngo.resources :project, :active_scaffold => true
  #end

  map.resources :activity, :active_scaffold => true
  map.resources :indicator, :active_scaffold => true
  map.resources :line_item, :active_scaffold => true
  map.resources :project, :active_scaffold => true
  map.resources :comments, :active_scaffold => true
  map.resources :field_helps, :active_scaffold => true
  map.resources :model_helps, :active_scaffold => true
  map.resources :organization, :collection => {:browse => :get}, :active_scaffold => true
  map.resources :funding_flow, :active_scaffold => true

  #ugly manual paths
  map.funding_sources_data_entry "funding_sources", :controller => 'funding_flows', :action => 'funding_sources'
  map.providers_data_entry "providers", :controller => 'funding_flows', :action => 'providers'

  map.page_comments "page_comments/:id", :controller => 'comments', :action => 'index', :type => 'ModelHelp'

  # DRY up the static page controller
  map.static_page ':page',
                  :controller => 'static_page',
                  :action => 'show',
                  :page => Regexp.new(%w[about contact ngo_dashboard govt_dashboard admin_dashboard].join('|'))

  map.root :controller => 'static_page', :action => 'index' #a replacement for public/index.html

end
