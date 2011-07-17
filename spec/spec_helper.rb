require 'rubygems'
require 'spork'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  # This file is copied to ~/spec when you run 'ruby script/generate rspec'
  # from the project root directory.
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path(File.join(File.dirname(__FILE__),'..','config','environment'))
  require 'spec/autorun'
  require 'spec/rails'
  require 'factory_girl'
  require 'shoulda'
  require 'authlogic/test_case'
  require 'database_cleaner'
  require 'email_spec'


  Dir[File.expand_path(File.join(File.dirname(__FILE__),'factories','**','*.rb'))].each {|f| require f}
  # Dir[File.expand_path(File.join(File.dirname(__FILE__),'spec','factories','**','*.rb'))].each {|f| require f} # from irb

  # Requires supporting files with custom matchers and macros, etc,
  # in ./support/ and its subdirectories.
  Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

  Spec::Runner.configure do |config|
    config.use_transactional_fixtures = true
    config.use_instantiated_fixtures  = false
    config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

    config.before :each do
      DatabaseCleaner.strategy = :truncation
      DatabaseCleaner.clean
    end

    config.include(EmailSpec::Helpers)
    config.include(EmailSpec::Matchers)
  end

end

Spork.each_run do
  # This code will be run each time you run your specs.

end

# --- Instructions ---
# - Sort through your spec_helper file. Place as much environment loading
#   code that you don't normally modify during development in the
#   Spork.prefork block.
# - Place the rest under Spork.each_run block
# - Any code that is left outside of the blocks will be ran during preforking
#   and during each_run!
# - These instructions should self-destruct in 10 seconds.  If they don't,
#   feel free to delete them.
#

def login( user = Factory.build(:reporter) )
  activate_authlogic
  UserSession.create user
end

shared_examples_for "a protected endpoint" do
  it { should redirect_to(login_path) }
  it { should set_the_flash.to("You must be logged in to access this page") }
end

shared_examples_for "comments_cacher" do
  it "caches comments count" do
    @commentable.comments_count.should == 0
    Factory.create(:comment, :commentable => @commentable)
    @commentable.reload.comments_count.should == 1
  end
end

shared_examples_for "location cloner" do
  it "should clone locations" do
    @location = Factory(:location)
    @original.locations << @location
    save_and_deep_clone
    @clone.locations.first.should == @location
  end
end

def save_and_deep_clone
  @original.save!
  @clone = @original.deep_clone
  @request2 = Factory(:data_request)
  @clone.data_response = @original.data_response.organization.latest_response
  @clone.save!
  @clone.reload #otherwise seems to cache the old has_many associations
end

def proj_funded_by(proj, funder, budget = 50, spend = 50)
  to = proj.data_response.organization
  Factory(:funding_flow, :from => funder, :to => to, :project => proj,
           :budget => budget, :spend => spend, :data_response => proj.response)
  proj.reload
  proj
end

def self_funded(proj, budget = 50, spend = 50)
  proj_funded_by(proj, proj.data_response.organization, budget, spend)
end

# setup for Ultimate Funding Source scenarios
def ufs_test_setup
  @org0 = Factory(:organization, :name => 'org0', :currency => 'USD')
  @org1 = Factory(:organization, :name => 'org1', :currency => 'USD')
  @org2 = Factory(:organization, :name => 'org2', :currency => 'USD')
  @org3 = Factory(:organization, :name => 'org3', :currency => 'USD')
  @org4 = Factory(:organization, :name => 'org4', :currency => 'USD')
  @org_with_no_data_response = Factory(:organization,
                                       :name => 'org_with_no_data_response')
  @org_with_empty_data_response = Factory(:organization,
                                          :name => 'org_with_empty_data_response')
  request = Factory(:data_request)

  Factory(:data_response, :organization => @org_with_empty_data_response,
          :data_request => request)

  @response0 = @org0.data_responses[0]
  @response1 = @org1.data_responses[0]
  @response2 = @org2.data_responses[0]
  @response3 = @org3.data_responses[0]
  @response4 = @org4.data_responses[0]

  @proj0 = Factory(:project, :name => 'p0', :data_response => @response0, :currency => "USD")
  @proj1 = Factory(:project, :name => 'p1', :data_response => @response1, :currency => "USD")
  @proj11 = Factory(:project, :name => 'p11', :data_response => @response1, :currency => "USD")
  @proj12 = Factory(:project, :name => 'p12', :data_response => @response1, :currency => "USD")
  @proj2 = Factory(:project, :name => 'p2', :data_response => @response2, :currency => "USD")
  @proj3 = Factory(:project, :name => 'p3', :data_response => @response3, :currency => "USD")
  @proj4 = Factory(:project, :name => 'p4', :data_response => @response4, :currency => "USD")
end

def ufs_without_chains(ufs)
  ufs.each{|fs| fs.delete(:org_chain)}
end

def ufs_equality(ufs, target)
  if ufs.size == 1 and ufs.size == target.size
    ufs = ufs.first; target = target.first
    # simple case, can do pretty compare
    ufs.ufs.should == target[:ufs]
    ufs.fa.should == target[:fa]
    ufs.budget.round(3).should == target[:budget]
    ufs.spend.round(3).should == target[:spend]
    # chain[:org_chain].should == target's after we add chains to test
  else
    raise 'collection comparison not implemented here'
    ufs.should == target
  end
end

def bd(integer)
  BigDecimal.new(integer.to_s)
end

def login_as_admin
  # mock current_response_is_latest? method for Users
  # CAUTION: current_response_is_latest? method of model
  # will probably be redefined for all future specs !?
  #User.class_eval{ def current_response_is_latest?; true; end }
  # does not work in this version of RSpec
  # User.any_instance.stubs(:current_response_is_latest?).returns(true)
  organization = Factory(:organization)
  @data_request = Factory(:data_request, :organization => organization) # we need a request in the system first
  @admin = Factory(:admin, :organization => organization)
  login @admin
end

def basic_setup_request
  @organization = Factory(:organization)
  @request      = Factory(:data_request, :organization => @organization)
end

def basic_setup_response
  @organization = Factory(:organization)
  @request      = Factory(:data_request, :organization => @organization)
  @response     = @organization.latest_response
end

def basic_setup_project
  @organization = Factory(:organization)
  @request      = Factory(:data_request, :organization => @organization)
  @response     = @organization.latest_response
  @project      = Factory(:project, :data_response => @response)
end

def basic_setup_activity
  @organization = Factory(:organization)
  @request      = Factory(:data_request, :organization => @organization)
  @response     = @organization.latest_response
  @project      = Factory(:project, :data_response => @response)
  @activity     = Factory(:activity, :data_response => @response, :project => @project)
end

def basic_setup_other_cost
  @organization = Factory(:organization)
  @request      = Factory(:data_request, :organization => @organization)
  @response     = @organization.latest_response
  @project      = Factory(:project, :data_response => @response)
  @other_cost   = Factory(:other_cost, :data_response => @response, :project => @project)
end

def basic_setup_sub_activity
  @organization = Factory(:organization)
  @request      = Factory(:data_request, :organization => @organization)
  @response     = @organization.latest_response
  @project      = Factory(:project, :data_response => @response)
  @activity     = Factory(:activity, :data_response => @response, :project => @project)
  @sub_activity = Factory(:sub_activity, :data_response => @response,
                          :activity => @activity, :provider => @organization)
end

def debug_model_objects
  p "organizations: #{Organization.count}"
  p "requests: #{DataRequest.count}"
  p "responses: #{DataResponse.count}"
  p "projects: #{Project.count}"
  p "activities: #{Activity.count}"
  p "sub_activities: #{SubActivity.count}"
end
