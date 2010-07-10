ActionController::Routing::Routes.draw do |map|
  # default routes are off

  map.coding "activities/code", :controller => 'activities', :action => 'code'
  # ugly manual paths
  map.funding_sources_data_entry "funding_sources", :controller => 'funding_sources', :action => 'index'
  map.providers_data_entry "providers", :controller => 'providers', :action => 'index'
  %w[activities funding_flows projects providers funding_sources model_helps comments].each do |model|
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

  map.resources :code_assignments, :only => [:index]
  map.manage_code_assignments 'manage_code_assignments', :controller => 'code_assignments', :action => :manage

  # DRY up the static page controller
  map.root :controller => 'static_page' #a replacement for public/index.html
  map.static_page ':page', :controller => 'static_page', :action => 'show', :page => Regexp.new(StaticPageController::PAGES.join('|'))
  map.ngo_dashboard 'ngo_dashboard', :controller => 'static_page', :action => 'show', :page => 'ngo_dashboard'
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
 # map.connect ':controller/:action/:id'
 # map.connect ':controller/:action/:id.:format'
end
