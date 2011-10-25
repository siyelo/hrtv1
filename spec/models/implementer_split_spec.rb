require File.dirname(__FILE__) + '/../spec_helper'

include DelayedJobSpecHelper

describe ImplementerSplit do
  describe "Associations:" do
    it { should belong_to :activity }
    it { should belong_to :organization }
  end

  describe "Attributes:" do
    it { should allow_mass_assignment_of(:activity_id) }
    it { should allow_mass_assignment_of(:organization_id) }
    it { should allow_mass_assignment_of(:budget) }
    it { should allow_mass_assignment_of(:spend) }
  end

  describe "Validations:" do
    it { should validate_presence_of(:organization_id) }
    it { should validate_numericality_of(:spend) }
    it { should validate_numericality_of(:budget) }

    it "should validate presence of organization_mask" do
      basic_setup_activity
      @split = ImplementerSplit.new(:data_response => @response,
        :activity => @activity)
      @split.save.should == false
      @split.errors.on(:organization_mask).should == "can't be blank"
    end

    it "should validate spend/budget greater than 0" do
      basic_setup_activity
      @split = ImplementerSplit.new(:data_response => @response,
        :activity => @activity, :organization => @organization,
        :spend => 0, :budget => 0)
      @split.save.should == false
      @split.errors.on(:spend).should == "must be greater than 0"
      @split.errors.on(:budget).should == "must be greater than 0"

      @split = ImplementerSplit.new(:data_response => @response,
        :activity => @activity, :organization => @organization,
        :spend => 0, :budget => "")
      @split.save.should == false
      @split.errors.on(:spend).should == "must be greater than 0"

      @split = ImplementerSplit.new(:data_response => @response,
        :activity => @activity, :organization => @organization,
        :spend => 1, :budget => 0)
      @split.save.should == true
      @split.errors.on(:budget).should be_nil
    end

    describe "implementer uniqueness" do
      # A known rails issue ? http://stackoverflow.com/questions/5482777/rails-3-uniqueness-validation-for-nested-fields-for
      it "should fail when trying to create two sub-activities with the same provider via Activity nested attribute API" do
        pending
        basic_setup_implementer_split
        attributes = {"name"=>"dsf", "start_date"=>"2010-08-02",
          "project_id"=>"#{@project.id}",
          "implementer_splits_attributes"=>
            {"0"=> {"spend"=>"2",
              "activity_id"=>"#{@activity.id}",
              "organization_mask"=>"#{@organization.id}", "budget"=>"4"},
            "1"=> {"spend"=>"3",
              "activity_id"=>"#{@activity.id}",
              "organization_mask"=>"#{@organization.id}", "budget"=>"6"}
            }, "description"=>"adfasdf", "end_date"=>"2010-08-04"}
        @activity.reload
        @activity.update_attributes(attributes).should be_false
        @activity.implementer_splits[1].errors.on(:organization_id).should == "must be unique"
      end

      it "should fail when trying to create two sub-activities with the same provider via Activity nested attribute API" do
        basic_setup_implementer_split
        attributes = {"name"=>"dsf", "start_date"=>"2010-08-02",
          "project_id"=>"#{@project.id}",
          "implementer_splits_attributes"=>
            {"0"=> {"spend"=>"10",
              "id"=>"#{@split.id}",
              "activity_id"=>"#{@activity.id}",
              "organization_mask"=>"#{@organization.id}",
              "budget"=>"20.0"},
            "1"=> {"spend"=>"30",
              "activity_id"=>"#{@activity.id}",
              "organization_mask"=>"#{@organization.id}", "budget"=>"40.0"}
            }, "description"=>"adfasdf", "end_date"=>"2010-08-04"}
        @activity.reload
        @activity.update_attributes(attributes).should be_false
        @activity.errors.full_messages.should include("Duplicate Implementers")
      end

      it "should enforce uniqueness via ImplementerSplit api" do
        basic_setup_implementer_split
        @split1 = Factory(:implementer_split, :activity => @activity,
          :organization => @organization)
        @split1.should_not be_valid
        @split1.errors.on(:organization_id).should == "must be unique"
      end
    end
  end

  describe "Custom validations" do
    before :each do
      basic_setup_activity
    end

    it "should validate Expenditure and/or Budget is present if nil" do
      @split = ImplementerSplit.new(:activity => @activity,
                 :budget => nil, :spend => nil)
      @split.save.should == false
      @split.errors.on(:spend).should include(' and/or Budget must be present')
    end

    it "should validate Expenditure and/or Budget is present if blank" do
      @split = ImplementerSplit.new(:activity => @activity,
                  :budget => "", :spend => "")
      @split.save.should == false
      @split.errors.on(:spend).should include(' and/or Budget must be present')
    end

    it "should fail when trying to create a split without spend/budget via Activity API " do
      attributes = {"name"=>"dsf", "start_date"=>"2010-08-02", "project_id"=>"#{@project.id}",
        "implementer_splits_attributes"=>
          {"0"=> {"spend"=>"", "budget"=>"",
            "activity_id"=>"#{@activity.id}",
            "organization_mask"=>"#{@organization.id}"},
          }, "description"=>"adfasdf", "end_date"=>"2010-08-04"}
      @activity.reload
      @activity.update_attributes(attributes).should be_false
      @activity.implementer_splits[0].errors.on(:spend).should == ' and/or Budget must be present'
    end

    it "should fail when trying to create a split without spend/budget via Activity API " do
      attributes = {"name"=>"dsf", "start_date"=>"2010-08-02", "project_id"=>"#{@project.id}",
        "implementer_splits_attributes"=>
          {"0"=> {"spend"=>"", "budget"=>"",
            "activity_id"=>"#{@activity.id}",
              "organization_mask"=>"#{@organization.id}"},
          }, "description"=>"adfasdf", "end_date"=>"2010-08-04"}
      @activity.reload
      @activity.update_attributes(attributes).should be_false
      @activity.implementer_splits[0].errors.on(:spend).should == ' and/or Budget must be present'
    end

    it "should only update splits via Activity API if updated_at is set" do
      attributes = {"name"=>"dsf", "start_date"=>"2010-08-02", "project_id"=>"#{@project.id}",
        "implementer_splits_attributes"=>
          {"0"=> {"spend"=>"1", "budget"=>"1",
            "activity_id"=>"#{@activity.id}",
            "organization_mask"=>"#{@organization.id}"},
          }, "description"=>"adfasdf", "end_date"=>"2010-08-04"}
      @activity.reload
      @activity.update_attributes(attributes).should be_true
    end

    it "should validate one OR the other" do
      @split = ImplementerSplit.new(:activity => @activity,
                  :budget => nil, :spend => "123.00", :organization => @organization)
      @split.save.should == true
    end
  end

  describe "#budget= and #spend=" do
    before :each do
      basic_setup_activity
      @split = Factory.build(:implementer_split, :activity => @activity)
    end

    it "allows nil value" do
      @split.budget = @split.spend = nil
      @split.budget.should == nil
      @split.spend.should == nil
    end

    it "rounds up to 2 decimals" do
      @split.budget = @split.spend = 10.12745
      @split.budget.to_f.should == 10.13
      @split.spend.to_f.should == 10.13
    end

    it "rounds down to 2 decimals" do
      @split.budget = @split.spend = 10.12245
      @split.budget.to_f.should == 10.12
      @split.spend.to_f.should == 10.12
    end
  end

  describe "saving sub activity updates the activity" do
    before :each do
      basic_setup_activity
    end

    it "should update the spend field on the parent activity" do
      @split = Factory.build :implementer_split, :activity => @activity,
        :spend => 74, :organization => @organization
      @split.save; @activity.reload; @activity.save
      @activity.spend.to_f.should == 74
    end

    it "should update the budget field on the parent activity" do
      @split = Factory.build :implementer_split, :activity => @activity,
        :budget => 74, :organization => @organization
      @split.save; @activity.reload;
      @activity.save # this updates the cache
      @activity.budget.to_f.should == 74
    end
  end

  it "should respond to organization_name" do
    basic_setup_implementer_split
    @split.organization_name.should == @organization.name
  end

  it "should return organization_mask as the org id" do
    org = Factory.build :organization
    split = Factory.build :implementer_split, :organization => org
    split.organization_mask.should == org.id
  end

  it "should respond to assign_or_create_organization" do
    Factory.build(:implementer_split).should respond_to(:assign_or_create_organization)
  end

  describe "#possible_double_count?" do
    before :each do
      @donor        = Factory(:organization, :name => "donor")
      @organization = Factory(:organization, :name => "self-implementer")
      @request      = Factory(:data_request, :organization => @organization)
      @response     = @organization.latest_response
      @project      = Factory(:project, :data_response => @response)
      @activity     = Factory(:activity, :project => @project,
                              :data_response => @response)
    end

    context "self implementer" do
      it "does not mark double count" do
        implementer_split = Factory(:implementer_split, :activity => @activity,
                                    :organization => @organization)

        implementer_split.possible_double_count?.should be_false
      end
    end

    context "non-hrt implementer" do
      it "does not mark double count" do
        organization2 = Factory(:organization, :raw_type => 'Non-Reporting')
        implementer_split = Factory(:implementer_split, :activity => @activity,
                                    :organization => organization2)

        implementer_split.possible_double_count?.should be_false
      end
    end

    context "another hrt implementer" do
      context "other implementer has submitted response" do
        it "marks double counting" do
          organization2 = Factory(:organization, :name => "other-hrt-implementer")
          response2     = organization2.latest_response
          project2      = Factory(:project, :data_response => response2)
          activity2     = Factory(:activity, :data_response => response2,
                                  :project => project2)

          implementer_split = Factory(:implementer_split,
                                      :activity => @activity,
                                      :organization => organization2)
          Factory(:implementer_split, :activity => activity2,
                  :organization => organization2)

          response2.state = 'accepted'; response2.save!

          implementer_split.reload.possible_double_count?.should be_true
        end
      end

      context "other implementer has not submitted their response" do
        it "does not marks double count" do
          organization2 = Factory(:organization, :name => "other-hrt-implementer")
          response2     = organization2.latest_response
          project2      = Factory(:project, :data_response => response2)
          activity2     = Factory(:activity, :data_response => response2,
                                  :project => project2)

          implementer_split = Factory(:implementer_split,
                                      :activity => @activity,
                                      :organization => organization2)
          Factory(:implementer_split, :activity => activity2,
                  :organization => organization2)

          response2.state = 'started'; response2.save!

          implementer_split.possible_double_count?.should be_false
        end
      end
    end
  end

  describe "#mark_double_counting" do
    before :each do
      donor    = Factory(:organization, :name => 'donor')
      @request  = Factory(:data_request, :organization => donor)
      response = donor.latest_response
      org1     = Factory(:organization, :name => "organization1")
      org2     = Factory(:organization, :name => "organization2")
      project  = Factory(:project, :data_response => response)
      activity = Factory(:activity, :id => 1, :data_response => response,
                         :project => project)
      split1 = Factory(:implementer_split, :id => 1,
        :activity => activity, :organization => org1, :double_count => false)
      split2 = Factory(:implementer_split, :id => 2,
        :activity => activity, :organization => org2, :double_count => false)
    end

    it "marks double counting from csv file" do
      file = File.open('spec/fixtures/activity_overview.csv')

      report = Reports::ActivityOverview.new(@request)
      rows = FasterCSV.parse(file, {:headers => true})

      rows.each{ |row| row['Actual Double-Count?'] = true }

      double_count_marker = ImplementerSplit.mark_double_counting(rows.to_csv)

      run_delayed_jobs

      splits = ImplementerSplit.all
      splits[0].double_count.should be_true
      splits[1].double_count.should be_true
    end

    it "reset double-count marks when nil" do
      file = File.open('spec/fixtures/activity_overview.csv')

      report = Reports::ActivityOverview.new(@request)
      rows = FasterCSV.parse(file, {:headers => true})

      rows.each{ |row| row['Actual Double-Count?'] = nil }

      double_count_marker = ImplementerSplit.mark_double_counting(rows.to_csv)

      run_delayed_jobs

      splits = ImplementerSplit.all
      splits[0].double_count.should be_nil
      splits[1].double_count.should be_nil
    end

    it "reset double-count marks when empty string" do
      file = File.open('spec/fixtures/activity_overview.csv')

      report = Reports::ActivityOverview.new(@request)
      rows = FasterCSV.parse(file, {:headers => true})

      rows.each{ |row| row['Actual Double-Count?'] = '' }

      double_count_marker = ImplementerSplit.mark_double_counting(rows.to_csv)

      run_delayed_jobs

      splits = ImplementerSplit.all
      splits[0].double_count.should be_nil
      splits[1].double_count.should be_nil
    end
  end
end
