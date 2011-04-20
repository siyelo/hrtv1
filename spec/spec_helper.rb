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
