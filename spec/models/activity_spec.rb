require File.dirname(__FILE__) + '/../spec_helper'

describe Activity do
  describe "Associations" do
    it { should belong_to :provider }
    it { should belong_to :data_response }
    it { should belong_to :project }
    it { should have_and_belong_to_many :organizations }
    it { should have_and_belong_to_many :beneficiaries }
    it { should have_many(:implementer_splits).dependent(:destroy) }
    it { should have_many(:sub_activities).dependent(:destroy) } #TODO deprecate
    it { should have_many(:implementers) }
    it { should have_many(:sub_implementers) } #TODO deprecate
    it { should have_many(:codes) }
    it { should have_many(:purposes) }
    it { should have_many(:code_assignments).dependent(:destroy) }
    it { should have_many(:comments).dependent(:destroy) }
    it { should have_many(:coding_budget).dependent(:destroy) }
    it { should have_many(:coding_budget_cost_categorization).dependent(:destroy) }
    it { should have_many(:coding_budget_district).dependent(:destroy) }
    it { should have_many(:coding_spend).dependent(:destroy) }
    it { should have_many(:coding_spend_cost_categorization).dependent(:destroy) }
    it { should have_many(:coding_spend_district).dependent(:destroy) }
    it { should have_many(:targets).dependent(:destroy) }
    it { should have_many(:outputs).dependent(:destroy) }
  end

  describe "Attributes" do
    it { should allow_mass_assignment_of(:name) }
    it { should allow_mass_assignment_of(:description) }
    it { should allow_mass_assignment_of(:start_date) }
    it { should allow_mass_assignment_of(:end_date) }
    it { should allow_mass_assignment_of(:project_id) }
    it { should allow_mass_assignment_of(:budget) }
    it { should allow_mass_assignment_of(:spend) }
    it { should allow_mass_assignment_of(:beneficiary_ids) }
    it { should allow_mass_assignment_of(:provider_id) }
    it { should allow_mass_assignment_of(:text_for_provider) }
    it { should allow_mass_assignment_of(:text_for_beneficiaries) }
    it { should allow_mass_assignment_of(:approved) }
    it { should allow_mass_assignment_of(:sub_activities_attributes) }
    it { should allow_mass_assignment_of(:organization_ids) }
    it { should allow_mass_assignment_of(:csv_project_name) }
    it { should allow_mass_assignment_of(:csv_provider) }
    it { should allow_mass_assignment_of(:csv_beneficiaries) }
    it { should allow_mass_assignment_of(:targets_attributes) }
    it { should allow_mass_assignment_of(:outputs_attributes) }
    it { should allow_mass_assignment_of(:am_approved_date) }
  end

  describe "Validations" do
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:data_response_id) }
    it { should validate_presence_of(:project_id) }
    it { should ensure_length_of(:name) }
    it "will return false if the activity start date is before the project start date" do
      basic_setup_response
      @project  = Factory(:project, :data_response => @response,
                         :start_date => '2011-01-01', :end_date => '2011-04-01')
      @activity = Factory.build(:activity, :data_response => @response, :project => @project,
                         :start_date => "2010-01-01", :end_date => "2011-03-01")
      @activity.should_not be_valid
    end

    it "will return false if the activity end date is after the project end date" do
      basic_setup_response
      @project  = Factory(:project, :data_response => @response,
                         :start_date => '2011-01-01', :end_date => '2011-04-01')
      @activity = Factory.build(:activity, :data_response => @response, :project => @project,
                         :start_date => "2001-03-01", :end_date => "2011-08-01")

      @activity.should_not be_valid
    end

    it "will return true if the activity start and end date are within the project start and end date" do
      basic_setup_response
      @project  = Factory(:project, :data_response => @response,
                         :start_date => '2011-01-01', :end_date => '2011-04-01')
      @activity = Factory.build(:activity, :data_response => @response, :project => @project,
                         :start_date => "2011-02-01", :end_date => "2011-03-01")

      @activity.should be_valid
    end
  end
  
  describe "update attributes" do
    context "when one sub_activity" do
      before :each do
        basic_setup_activity
        attributes = {"name"=>"dsf", "start_date"=>"2010-08-02", "project_id"=>"#{@project.id}", 
          "sub_activities_attributes"=>
            {"0"=>{"spend_mask"=>"10", "data_response_id"=>"#{@response.id}", "provider_mask"=>"#{@organization.id}", 
            "budget_mask"=>"20.0", "_destroy"=>""}
            }, "description"=>"adfasdf", "end_date"=>"2010-08-04"}
        @activity.reload
        @activity.update_attributes(attributes).should be_true
      end
    
      it "should maintain the activites budget/spend cache when creating a new sub_activity" do
        @activity.sub_activities.size.should == 1
        @activity.sub_activities[0].implementer.should == @organization
        @activity.sub_activities[0].spend.to_f.should == 10
        @activity.sub_activities[0].budget.to_f.should == 20
        @activity.reload
        @activity.spend.to_f.should == 10
        @activity.budget.to_f.should == 20
      end

      it "should not call activity cache update more than once" do
        pending #tricky to count the number of method calls on the callback
      end

      it "should leave the sa callbacks intact" do
        SubActivity.after_save.should include(:update_activity_cache)
      end
    end
    
    context "when two sub_activities" do
      before :each do
        basic_setup_sub_activity
        @implementer2 = Factory :organization
        @sub_activity2 = Factory(:sub_activity, :data_response => @response,
                                 :activity => @activity, :provider => @implementer2)
        
        attributes = {"name"=>"dsf", "start_date"=>"2010-08-02", "project_id"=>"#{@project.id}", 
          "sub_activities_attributes"=>
            {"0"=>
              {"spend_mask"=>"10", "id"=>"#{@sub_activity.id}", "data_response_id"=>"#{@response.id}", "provider_mask"=>"#{@organization.id}", "budget_mask"=>"20.0"},
            "1"=>
              {"spend_mask"=>"20", "id"=>"#{@sub_activity2.id}", "data_response_id"=>"#{@response.id}", "provider_mask"=>"#{@implementer2.id}", "budget_mask"=>"40.0"}
            }, "description"=>"adfasdf", "end_date"=>"2010-08-04"}
        @activity.reload
        @activity.update_attributes(attributes).should be_true
      end
    
      it "should maintain the activites budget/spend cache when creating a new sub_activity" do
        @activity.sub_activities.size.should == 2
        @activity.sub_activities[0].implementer.should == @organization
        @activity.sub_activities[0].spend.to_f.should == 10
        @activity.sub_activities[0].budget.to_f.should == 20        
        @activity.sub_activities[1].implementer.should == @implementer2
        @activity.sub_activities[1].spend.to_f.should == 20
        @activity.sub_activities[1].budget.to_f.should == 40
        @activity.reload
        @activity.spend.to_f.should == 30
        @activity.budget.to_f.should == 60
      end
    
      it "should not call activity cache update more than once" do
        pending #tricky to count the number of method calls on the callback
      end
      
      it "should leave the sa callbacks intact" do
        SubActivity.after_save.should include(:update_activity_cache)
      end
    end
  end

  
  describe "new" do
    context "when creating one sub activity" do
      before :each do
        basic_setup_project
        @attributes = { "name"=>"new activity", "start_date"=>"2010-08-02", "project_id"=>"#{@project.id}", 
          "sub_activities_attributes"=>
            {"0"=>{"spend_mask"=>"10", "data_response_id"=>"#{@response.id}", "provider_mask"=>"#{@organization.id}", 
            "budget_mask"=>"20.0", "_destroy"=>""}
            }, "description"=>"adfasdf", "end_date"=>"2010-08-04", "data_response_id"=>"#{@response.id}"}
        @activity = Activity.new(@attributes)
      end
    
      it "should instantiate new activity with cache values already calculated" do
        @activity.sub_activities.size.should == 1
        @activity.sub_activities[0].implementer.should == @organization
        @activity.sub_activities[0].spend.to_f.should == 10
        @activity.sub_activities[0].budget.to_f.should == 20
        @activity.spend.to_f.should == 10
        @activity.budget.to_f.should == 20
      end
    
      it "should call activity_cache_update once" do
        pending #tricky to count the number of method calls on the callback
      end
    
      it "should leave the sa callbacks intact" do
        SubActivity.after_save.should include(:update_activity_cache)
      end
    end    
    
    context "when (bulk) creating more than one sub activity" do
      before :each do
        basic_setup_project
        @implementer2 = Factory :organization
        @implementer3 = Factory :organization
        @attributes = { "name"=>"new activity", "start_date"=>"2010-08-02", "project_id"=>"#{@project.id}", 
          "sub_activities_attributes"=>
            {"0"=>{"spend_mask"=>"10", "data_response_id"=>"#{@response.id}", "provider_mask"=>"#{@organization.id}", 
            "budget_mask"=>"20.0", "_destroy"=>""},
            "1"=>{"spend_mask"=>"20", "data_response_id"=>"#{@response.id}", "provider_mask"=>"#{@implementer2.id}", 
            "budget_mask"=>"40.0", "_destroy"=>""},
            "2"=>{"spend_mask"=>"40", "data_response_id"=>"#{@response.id}", "provider_mask"=>"#{@implementer3.id}", 
            "budget_mask"=>"60.0", "_destroy"=>""}
            }, "description"=>"adfasdf", "end_date"=>"2010-08-04", "data_response_id"=>"#{@response.id}"}
        @activity = Activity.new(@attributes)
      end
    
      it "should instantiate new activity with cache values already calculated" do
        @activity.sub_activities.size.should == 3
        @activity.sub_activities[0].implementer.should == @organization
        @activity.sub_activities[0].spend.to_f.should == 10
        @activity.sub_activities[0].budget.to_f.should == 20
        @activity.sub_activities[1].implementer.should == @implementer2
        @activity.sub_activities[1].spend.to_f.should == 20
        @activity.sub_activities[1].budget.to_f.should == 40        
        @activity.sub_activities[2].implementer.should == @implementer3
        @activity.sub_activities[2].spend.to_f.should == 40
        @activity.sub_activities[2].budget.to_f.should == 60
        @activity.spend.to_f.should == 70
        @activity.budget.to_f.should == 120
      end
      
      it "should call activity_cache_update once" do
        pending #tricky to count the number of method calls on the callback
      end
      
      it "should call activity_cache_update once on saving" do
        pending
        # FIXME: this is still doing callback for each nested sub activity - will be slow!
      end
    
      it "should leave the sa callbacks intact" do
        SubActivity.after_save.should include(:update_activity_cache)
      end
    end
  
  
  end

  describe "download activity template" do
    it "returns the correct fields in the activity template" do
      organization  = Factory(:organization,
                              :fiscal_year_start_date => "2009-10-01",
                              :fiscal_year_end_date => "2010-09-30")
      data_request  = Factory(:data_request, :organization => organization)
      data_response = organization.latest_response
      Timecop.freeze(Date.parse("2009-10-15"))
      header_row = Activity.download_template(data_response)
      header_row.should == "Project Name,Activity Name,Activity Description,Provider,Jul '08 - Sep '08 Spend,Oct '08 - Dec '08 Spend,Jan '09 - Mar '09 Spend,Apr '09 - Jun '09 Spend,Jul '09 - Sep '09 Spend,Jul '09 - Sep '09 Budget,Oct '09 - Dec '09 Budget,Jan '10 - Mar '10 Budget,Apr '10 - Jun '10 Budget,Jul '10 - Sep '10 Budget,Beneficiaries,Targets,Start Date,End Date,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,Id\n"
    end

    it "should return csv header" do
      organization  = Factory(:organization)
      request        = Factory(:data_request, :organization => organization)
      response      = organization.latest_response
      Activity.file_upload_columns(response).should == [
        'Project Name',
        'Activity Name',
        'Activity Description',
        'Provider',
        "Apr '10 - Jun '10 Spend",
        "Jul '10 - Sep '10 Spend",
        "Oct '10 - Dec '10 Spend",
        "Jan '11 - Mar '11 Spend",
        "Apr '11 - Jun '11 Spend",
        "Apr '11 - Jun '11 Budget",
        "Jul '11 - Sep '11 Budget",
        "Oct '11 - Dec '11 Budget",
        "Jan '12 - Mar '12 Budget",
        "Apr '12 - Jun '12 Budget",
        'Beneficiaries',
        'Targets',
        'Start Date',
        'End Date']
    end
  end

  describe "#download_template" do
    it "should return template" do
      basic_setup_activity
      #@activity.targets << Factory(:target)
      csv = Activity.download_template(@response, [@activity])
      rows = FasterCSV.parse(csv)
      rows[0].should == Activity.file_upload_columns_with_id_col(@response)
      rows[1][0].should == @activity.project.try(:name)
      rows[1][1].should == @activity.name
      rows[1][2].should == @activity.description
      rows[1][3].should == @activity.provider.try(:name)
      rows[1][4].to_s.should == @activity.spend.to_s
      rows[1][5].to_s.should == @activity.budget.to_s
      rows[1][6].should == @activity.beneficiaries.map{|l| l.short_display}.join(',')
      rows[1][7].should == @activity.targets.map{|o| o.description}.join("")
      rows[1][8].should == @activity.start_date.to_s
      rows[1][9].should == @activity.end_date.to_s
    end
  end

  describe "organization_name" do
    it "returns organization nane" do
      @organization = Factory(:organization, :name => "Organization1")
      @request      = Factory(:data_request, :organization => @organization)
      @response     = @organization.latest_response
      @project      = Factory(:project, :data_response => @response)
      @activity     = Factory(:activity, :data_response => @response, :project => @project)
      @activity.organization_name.should == "Organization1"
    end
  end

  describe "sub-activities" do
    it "creates a sub activitiy in the initialization of the activity" do
      basic_setup_project
      @activity = Activity.new(:data_response_id => @response.id, :project_id => @project_id)
      @activity.sub_activities.size.should == 1
      @activity.sub_activities.first.provider.should == @organization
    end
  end

  describe "gets budget and spend from sub activities" do
    before :each do 
      basic_setup_activity
      @sa = Factory(:sub_activity, :activity => @activity, :data_response => @response, :budget => 25, :spend => 10)
      @activity.reload
    end

    it "activity.budget should be the total of sub activities(1)" do
      @activity.budget.to_f.should == 25
    end

    it "activity.spend should be the total of sub activities(1)" do
      @activity.spend.to_f.should == 10
    end

    it "refreshes the amount if the amount of the sub-activity changes" do
      @sa.spend = 13; @sa.budget = 29; @sa.save!; @activity.reload
      @activity.spend.to_f.should == 13
      @activity.budget.to_f.should == 29
    end

    describe "works with more than one sub activity" do
      before :each do
        @sa1 = Factory(:sub_activity, :activity => @activity, :data_response => @response, :budget => 125, :spend => 100)
        @activity.reload
      end
      it "activity.budget should be the total of sub activities(2)" do
        @activity.budget.to_f.should == 150
      end

      it "activity.spend should be the total of sub activities(2)" do
        @activity.spend.to_f.should == 110
      end

      it "refreshes the amount if the amount of the sub-activity changes" do
        @sa.spend = 20; @sa.budget = 35; @sa.save!; @activity.reload
        @activity.spend.to_f.should == 120
        @activity.budget.to_f.should == 160
      end
    end

    it "should not allow you to set the activities budget directly" do
      expect { budget }.should raise_error
    end

    it "should not allow you to set the activities spend directly" do
      expect { spend }.should raise_error
    end
  end

  describe "can show who we provided money to (providers)" do
    context "on a single project" do
      it "should have at least 1 provider" do
        basic_setup_project
        our_org   = Factory(:organization)
        other_org = Factory(:organization)
        flow      = Factory(:funding_flow,
                            :from => our_org, :to => other_org, :project => @project)
        activity  = Factory(:activity, :data_response => @response,
                            :project => @project, :provider => other_org )
        activity.provider.should == other_org # duh
      end
    end
  end
  

  it "cannot be edited once approved" do
    basic_setup_activity
    @activity.approved.should == nil
    @activity.approved = true
    @activity.save!
    @activity.name = "blarpants"
    @activity.save.should == false
  end

  describe "counter cache" do
    context "comments cache" do
      before :each do
        basic_setup_activity
        @commentable = @activity
      end

      it_should_behave_like "comments_cacher"
    end

    it "caches sub activities count" do
      basic_setup_activity
      @activity.sub_activities_count.should == 0
      Factory(:sub_activity, :data_response => @response,
              :provider => @organization, :activity => @activity)
      @activity.reload.sub_activities_count.should == 1
    end
  end

  describe "deep cloning" do
    before :each do
      basic_setup_activity
      @original = @activity #for shared examples
    end

    it "should clone associated code assignments" do
      @ca = Factory(:code_assignment, :activity => @activity)
      save_and_deep_clone
      @clone.code_assignments.count.should == 1
      @clone.code_assignments[0].code.should == @ca.code
      @clone.code_assignments[0].amount.should == @ca.amount
      @clone.code_assignments[0].activity.should_not == @activity
      @clone.code_assignments[0].activity.should == @clone
    end

    it "should clone organizations" do
      @orgs = [Factory(:organization)]
      @activity.organizations << @orgs
      save_and_deep_clone
      @clone.organizations.should == @orgs
    end

    it "should clone beneficiaries" do
      @benefs = [Factory(:beneficiary)]
      @activity.beneficiaries << @benefs
      save_and_deep_clone
      @clone.beneficiaries.should == @benefs
    end
  end

  describe "#amount_for_provider" do
    before :each do
      basic_setup_activity
    end

    context "normal activity" do
      it "should returns full amount for org1 when it is implementer" do
        @activity.amount_for_provider(@activity.provider, :budget).should == @activity.budget
      end

      it "should returns 0 when given org is not implementer" do
        @activity.amount_for_provider(Factory(:organization), :budget).should == 0
      end
    end

    context "sub activities" do
      it "looks for amount in sub-activity" do
        @subact = Factory(:sub_activity, :data_response => @response,
                          :activity => @activity, :budget => 10)
        @activity.sub_activities.reload
        @activity.amount_for_provider(@subact.provider, :budget).should == 10
      end
    end
  end

  describe "purposes" do
    it "should return only those codes designated as Purpose codes" do
      basic_setup_activity
      @purpose1    = Factory(:purpose, :short_display => 'purp1')
      @purpose2    = Factory(:mtef_code, :short_display => 'purp2')
      @input       = Factory(:input, :short_display => 'input')
      Factory(:coding_budget, :activity => @activity, :code => @purpose1,
        :amount => 5, :cached_amount => 5)
      Factory(:coding_budget, :activity => @activity, :code => @purpose2,
                 :amount => 15, :cached_amount => 15)
      Factory(:coding_budget_cost_categorization, :activity => @activity, :code => @input,
        :amount => 5, :cached_amount => 5)
      @activity.purposes.should == [@purpose1, @purpose2]
    end
  end

  describe "#self.find_or_initialize_from_file" do
    context "when CSV has implementer value of: 'Shyira HD District Hospital'" do
      before :each do
        @organization   = Factory(:organization)
        @request        = Factory(:data_request, :organization => @organization)
        @response       = @organization.latest_response
        @project        = Factory(:project, :data_response => @response, :name => "project1",
                          :start_date => '2012-01-01', :end_date => '2012-12-12')
        @activities_csv = File.join(Rails.root, 'spec', 'fixtures', 'activities_bulk.csv')
        @doc            = FasterCSV.open(@activities_csv, {:headers => true})
        @implementer    = Factory(:organization, :name => "Shyira HD District Hospital | Nyabihu")
        @activities     = Activity.find_or_initialize_from_file(@response, @doc, @project.id)
      end

      it "recognizes the correct project" do
        @activities[0].should be_valid
        @activities[0].project.should == @project
      end

      it "should create a budget and spend automatically for the activities" do
        @activities[0].sub_activities.count.should == 1
        @activities[0].sub_activities[0].data_response.should == @response
        @activities[0].sub_activities[0].organization.should == @organization
      end

      it "recognizes the correct implementer: 'Shyira HD District Hospital | Nyabihu'" do
        @activities.count.should == 1
        @activities[0].implementer_splits.first.implementer.should == @implementer
      end

      it "recognizes non-standard dates" do
        @activities[0].start_date.to_s.should  == '2012-01-01'
        @activities[0].end_date.to_s.should    == '2012-12-12'
      end
    end

    context "when CSV has an existing project" do
      it "assigns existing project to the activity from the organization's response" do
        organization1  = Factory(:organization)
        request        = Factory(:data_request, :organization => organization1)
        response1      = organization1.latest_response
        project        = Factory(:project, :data_response => response1)
        activities_csv = File.join(Rails.root, 'spec', 'fixtures', 'activities_bulk.csv')
        doc            = FasterCSV.open(activities_csv, {:headers => true})

        # project named: 'project1' in the organization uploading the file
        project1       = Factory(:project, :name => 'project1', :data_response => response1)

        organization2  = Factory(:organization)
        response2      = organization2.latest_response
        # project named: 'project1' in the other organization
        project2       = Factory(:project, :name => 'project1', :data_response => response2)

        activities = Activity.find_or_initialize_from_file(response1, doc, project.id)
        activities.count.should == 1
        activities[0].project.should == project1
      end
    end
  end

  describe "#locations" do
    it "returns uniq locations only from district classifications" do
      basic_setup_activity
      location1 = Factory(:location)
      location2 = Factory(:location)
      location3 = Factory(:location)
      location4 = Factory(:location)
      Factory(:coding_budget_district, :activity => @activity, :code => location1)
      Factory(:coding_budget_district, :activity => @activity, :code => location2)
      Factory(:coding_spend_district, :activity => @activity, :code => location2)
      Factory(:coding_budget, :activity => @activity, :code => location3)
      Factory(:coding_spend, :activity => @activity, :code => location4)

      @activity.locations.length.should == 2
      @activity.locations.should include(location1)
      @activity.locations.should include(location2)
    end
  end
end


# == Schema Information
#
# Table name: activities
#
#  id                                    :integer         not null, primary key
#  name                                  :string(255)
#  created_at                            :datetime
#  updated_at                            :datetime
#  provider_id                           :integer
#  description                           :text
#  type                                  :string(255)
#  budget                                :decimal(, )
#  spend_q1                              :decimal(, )
#  spend_q2                              :decimal(, )
#  spend_q3                              :decimal(, )
#  spend_q4                              :decimal(, )
#  start_date                            :date
#  end_date                              :date
#  spend                                 :decimal(, )
#  text_for_provider                     :text
#  text_for_targets                      :text
#  text_for_beneficiaries                :text
#  spend_q4_prev                         :decimal(, )
#  data_response_id                      :integer
#  activity_id                           :integer
#  approved                              :boolean
#  CodingBudget_amount                   :decimal(, )     default(0.0)
#  CodingBudgetCostCategorization_amount :decimal(, )     default(0.0)
#  CodingBudgetDistrict_amount           :decimal(, )     default(0.0)
#  CodingSpend_amount                    :decimal(, )     default(0.0)
#  CodingSpendCostCategorization_amount  :decimal(, )     default(0.0)
#  CodingSpendDistrict_amount            :decimal(, )     default(0.0)
#  budget_q1                             :decimal(, )
#  budget_q2                             :decimal(, )
#  budget_q3                             :decimal(, )
#  budget_q4                             :decimal(, )
#  budget_q4_prev                        :decimal(, )
#  comments_count                        :integer         default(0)
#  sub_activities_count                  :integer         default(0)
#  spend_in_usd                          :decimal(, )     default(0.0)
#  budget_in_usd                         :decimal(, )     default(0.0)
#

