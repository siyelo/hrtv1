# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true
end

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
    Factory.create(:comment, :commentable => @commentable)
    @commentable.reload.comments_count.should == 2
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
  @clone.data_response = Factory.create(:data_response)
  @clone.save!
  @clone.reload #otherwise seems to cache the old has_many associations
end
