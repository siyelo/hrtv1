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
    it { should allow_mass_assignment_of(:updated_at) }
  end

  describe "Validations:" do
    it { should validate_numericality_of(:spend) }
    it { should validate_numericality_of(:budget) }

    it "should validate presence of provider_mask" do
      basic_setup_activity
      @split = ImplementerSplit.new(:data_response => @response,
        :activity => @activity)
      @split.save.should == false
      @split.errors.on(:provider_mask).should == "can't be blank"
    end

    describe "implementer uniqueness" do
      # A known rails issue ? http://stackoverflow.com/questions/5482777/rails-3-uniqueness-validation-for-nested-fields-for
      it "should fail when trying to create two sub-activities with the same provider via Activity nested attribute API" do
        pending
        basic_setup_implementer_split
        attributes = {"name"=>"dsf", "start_date"=>"2010-08-02",
          "project_id"=>"#{@project.id}",
          "implementer_splits_attributes"=>
            {"0"=> {"updated_at" => Time.now, "spend"=>"2",
              "activity_id"=>"#{@activity.id}",
              "provider_mask"=>"#{@organization.id}", "budget"=>"4"},
            "1"=> {"updated_at" => Time.now, "spend"=>"3",
              "activity_id"=>"#{@activity.id}",
              "provider_mask"=>"#{@organization.id}", "budget"=>"6"}
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
            {"0"=> {"updated_at" => Time.now,"spend"=>"10",
              "id"=>"#{@split.id}",
              "activity_id"=>"#{@activity.id}",
              "provider_mask"=>"#{@organization.id}",
              "budget"=>"20.0"},
            "1"=> {"updated_at" => Time.now, "spend"=>"30",
              "activity_id"=>"#{@activity.id}",
              "provider_mask"=>"#{@organization.id}", "budget"=>"40.0"}
            }, "description"=>"adfasdf", "end_date"=>"2010-08-04"}
        @activity.reload
        @activity.update_attributes(attributes).should be_false
        @activity.errors.full_messages.should include("Duplicate Implementers")
      end

      it "should enforce uniqueness via SubActivity api" do
        basic_setup_implementer_split
        @split1 = Factory(:implementer_split, :activity => @activity,
          :organization => @organization)
        @split1.should_not be_valid
        @split1.errors.on(:organization_id).should == "must be unique"
      end
    end
  end


  it "should return provider_mask as the org id" do
    org = Factory.build(:organization)
    split = Factory.build :implementer_split, :organization => org
    split.provider_mask.should == org.id
  end

  it "should support old provider/implementer API" do
    pending
  end

end