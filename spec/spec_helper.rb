require 'rubygems'
require 'spork'
require File.expand_path(File.join(File.dirname(__FILE__), 'lib', 'delayed_job_spec_helper'))

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

  require 'shoulda'
  require 'authlogic/test_case'
  require 'database_cleaner'
  require 'email_spec'

  # Requires supporting files with custom matchers and macros, etc,
  # in ./support/ and its subdirectories.
  Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

  Spec::Runner.configure do |config|
    config.use_transactional_fixtures = true
    config.use_instantiated_fixtures  = false
    config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

    config.before :each do
      DatabaseCleaner.strategy = :truncation#, {:except => %w[currencies]}
      DatabaseCleaner.clean
      DeferredGarbageCollection.start
    end

    config.after(:all) do
      DeferredGarbageCollection.reconsider
    end

    config.include(EmailSpec::Helpers)
    config.include(EmailSpec::Matchers)

    config.before(:each) do
      Timecop.return
    end
  end
end

Spork.each_run do
  # This code will be run each time you run your specs.

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

  # fix for spork not reloading models
  require 'factory_girl'
  Dir[File.expand_path(File.join(File.dirname(__FILE__),'factories','**','*.rb'))].each {|f| require f}
  # Dir[File.expand_path(File.join(File.dirname(__FILE__),'spec','factories','**','*.rb'))].each {|f| require f} # from irb

  def login( user = Factory.build(:reporter) )
    activate_authlogic
    UserSession.create user
  end

  shared_examples_for "a protected endpoint" do
    it { should redirect_to(login_path) }
    it { should set_the_flash.to("You must be logged in to access this page") }
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
    Factory(:funding_flow, :from => funder, :project => proj,
             :budget => budget, :spend => spend)
    proj.reload
    proj
  end

  def self_funded(proj, budget = 50, spend = 50)
    proj_funded_by(proj, proj.data_response.organization, budget, spend)
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

  def basic_setup_response
    basic_setup_response_for_controller
    @request = @data_request
    @response = @data_response
  end

  #controller specs don't like you setting @request, @response
  def basic_setup_response_for_controller
    @organization = Factory(:organization)
    request      = Factory(:data_request, :organization => @organization)
    @data_request = request
    @data_response     = @organization.latest_response
  end

  def basic_setup_project
    @organization = Factory(:organization)
    @other_org    = Factory(:organization)
    @request      = Factory(:data_request, :organization => @organization)
    @response     = @organization.latest_response
    @project      = Project.new(:data_response => @response,
                      :name => "non_factory_project_name_#{rand(100_000_000)}",
                      :description => "proj descr",
                      :start_date => "2010-01-01",
                      :end_date => "2011-01-01",
                      :in_flows_attributes => [:organization_id_from => @other_org.id,
                          :budget => 10, :spend => 20])
    @project.save!
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

  def basic_setup_implementer_split
    basic_setup_implementer_split_for_controller
    @request = @data_request
    @response = @data_response
  end

  def basic_setup_implementer_split_for_controller
    @organization = Factory(:organization)
    @data_request      = Factory(:data_request, :organization => @organization)
    @data_response     = @organization.latest_response
    @project      = Factory(:project, :data_response => @data_response)
    @activity     = Factory(:activity, :data_response => @data_response, :project => @project)
    @split = Factory(:implementer_split, :activity => @activity,
      :organization => @organization)
    @activity.save #recalculate implementer split total on activity
  end

  def basic_setup_funding_flow
    @donor = Factory(:organization)
    @organization = Factory(:organization)
    @request      = Factory(:data_request, :organization => @organization)
    @response     = @organization.latest_response
    @project      = Factory(:project, :data_response => @response)
    @funding_flow = Factory(:funding_flow, :project => @project,
                            :from => @donor)
  end

  def setup_activity_in_fiscal_year(fy_start, fy_end, attributes, currency = 'USD')
    @organization = Factory(:organization,
                            :fiscal_year_start_date => fy_start,
                            :fiscal_year_end_date => fy_end,
                            :currency => currency)
    @request      = Factory(:data_request, :organization => @organization)
    @response     = @organization.latest_response
    @project      = Factory(:project, :data_response => @response)
    @activity     = Factory(:activity, {:data_response => @response,
                                        :project => @project}.merge(attributes))
  end

  def write_temp_xls(rows)
    Spreadsheet.client_encoding = "UTF-8//IGNORE"
    book = Spreadsheet::Workbook.new
    sheet1 = book.create_worksheet

    rows.each_with_index do |row, row_index|
      row.each_with_index do |cell, column_index|
        sheet1[row_index, column_index] = cell
      end
    end
    filename =  File.join(Rails.root, 'tmp', 'temporary_spec.xls')
    book.write filename
    filename
  end

  def write_xls_with_header(rows)
    row = ['Project Name','Project Description','Project Start Date',
           'Project End Date','Activity Name','Activity Description',
           'Id','Implementer','Past Expenditure','Current Budget']
    rows.insert(0,row)
    write_temp_xls(rows)
  end

  def write_temp_csv(csv_string)
    filename =  File.join(Rails.root, 'tmp', 'temporary_spec.csv')
    FasterCSV.open(filename, "w", :force_quotes => true) do |file|
      FasterCSV.parse(csv_string).each do |line|
        file << line
      end
    end
    filename
  end

  def write_csv_with_header(csv_string)
    header = <<-EOS
Project Name,Project Description,Project Start Date,Project End Date,Activity Name,Activity Description,Id,Implementer,Past Expenditure,Current Budget
EOS
    write_csv(header + csv_string)
  end

  def write_csv(csv_string)
    write_temp_csv(csv_string)
  end
end
