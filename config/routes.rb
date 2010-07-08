ActionController::Routing::Routes.draw do |map|
<<<<<<< HEAD

  # GR - we'll namespace these as soon as the tests are running
  #map.namespace :ngo do |ngo|
  #  ngo.resources :project, :active_scaffold => true
  #end
=======
  #ugly manual paths
  map.funding_sources_data_entry "funding_sources", :controller => 'funding_sources', :action => 'index'
  map.providers_data_entry "providers", :controller => 'providers', :action => 'index'
  %w[activities funding_flows projects providers funding_sources].each do |model|
    map.create_from_file model+"/create_from_file", :controller => model, :action => "create_from_file"
  end

>>>>>>> 76b2b7a... refactoring broke workflow links, funding_flows need attention

<<<<<<< HEAD
  map.resources :activity, :active_scaffold => true
  map.resources :indicator, :active_scaffold => true
  map.resources :line_item, :active_scaffold => true
  map.resources :project, :active_scaffold => true
  map.resources :comments, :active_scaffold => true
  map.resources :field_helps, :active_scaffold => true
  map.resources :model_helps, :active_scaffold => true
  map.resources :organization, :collection => {:browse => :get}, :active_scaffold => true
=======
  map.resources :activities, :active_scaffold => true
  map.resources :indicators, :active_scaffold => true 
  map.resources :line_items, :active_scaffold => true 
  map.resources :projects, :active_scaffold => true 
  map.resources :comments, :active_scaffold => true 
  map.resources :field_helps, :active_scaffold => true 
  map.resources :model_helps, :active_scaffold => true 
  map.resources :organizations, :collection => {:browse => :get}, :active_scaffold => true
>>>>>>> 89eb0b4... nicer routes and workflow
  map.resources :funding_flows, :active_scaffold => true
  map.resources :codes, :active_scaffold => true



  map.page_comments "page_comments/:id", :controller => 'comments', :action => 'index', :type => 'ModelHelp'

  # DRY up the static page controller
  map.static_page ':page',
                  :controller => 'static_page',
                  :action => 'show',
                  :page => Regexp.new(%w[about contact ngo_dashboard govt_dashboard admin_dashboard].join('|'))

  map.root :controller => 'static_page', :action => 'index' #a replacement for public/index.html

<<<<<<< HEAD
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'

=======
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
>>>>>>> 76b2b7a... refactoring broke workflow links, funding_flows need attention
end
