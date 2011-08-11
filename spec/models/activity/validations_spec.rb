require File.dirname(__FILE__) + '/../../spec_helper'

describe Activity, "Validations" do
  describe "#has_budget_or_spend?" do
    before :each do
      basic_setup_project
    end

    it "will return true if the activity has a budget" do
      @activity = Factory(:activity, :data_response => @response,
                          :project => @project, :budget => 20, :spend => nil)
      @activity.has_budget_or_spend?.should be_true
    end

    it "will return false if the activity has a spend" do
      @activity = Factory(:activity, :data_response => @response,
                          :project => @project, :budget => nil, :spend => 20)
      @activity.has_budget_or_spend?.should be_true
    end

    it "will return false if the activity has no budget or spend" do
      @activity = Factory(:activity, :data_response => @response,
                          :project => @project, :budget => nil, :spend => nil)
      @activity.has_budget_or_spend?.should be_false
    end
  end

  describe "#classification_errors_by_type" do
    before :each do
      basic_setup_activity
    end

    context "invalid classification type" do
      it "raises error" do
        lambda { @activity.classification_errors_by_type('invalid')
          }.should raise_error(Activity::Validations::InvalidClassificationType)
      end
    end

    context "purposes" do
      context "is not classified" do
        it "returns errors" do
          @activity.coding_budget_valid = false
          @activity.coding_spend_valid = false
          errors = @activity.classification_errors_by_type('purposes')
          errors.should include('Purposes by Current Budget are not classified')
          errors.should include('Purposes by Past Expenditure are not classified')
        end
      end

      context "is classified" do
        it "returns errors" do
          @activity.coding_budget_valid = true
          @activity.coding_spend_valid = true
          errors = @activity.classification_errors_by_type('purposes')
          errors.should be_empty
        end
      end
    end

    context "inputs" do
      context "is not classified" do
        it "returns errors" do
          @activity.coding_budget_cc_valid = false
          @activity.coding_spend_cc_valid = false
          errors = @activity.classification_errors_by_type('inputs')
          errors.should include('Inputs by Current Budget are not classified')
          errors.should include('Inputs by Past Expenditure are not classified')
        end
      end

      context "is classified" do
        it "returns errors" do
          @activity.coding_budget_cc_valid = true
          @activity.coding_spend_cc_valid = true
          errors = @activity.classification_errors_by_type('inputs')
          errors.should be_empty
        end
      end
    end

    context "locations" do
      context "is not classified" do
        it "returns errors" do
          @activity.coding_budget_district_valid = false
          @activity.coding_spend_district_valid = false
          errors = @activity.classification_errors_by_type('locations')
          errors.should include('Locations by Current Budget are not classified')
          errors.should include('Locations by Past Expenditure are not classified')
        end
      end

      context "is classified" do
        it "returns errors" do
          @activity.coding_budget_district_valid = true
          @activity.coding_spend_district_valid = true
          errors = @activity.classification_errors_by_type('locations')
          errors.should be_empty
        end
      end
    end
  end
end
