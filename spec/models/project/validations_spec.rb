require File.dirname(__FILE__) + '/../../spec_helper'

describe Project, "Validations" do
  before :each do
    basic_setup_project
    @donor1    = Factory :organization
    @donor2    = Factory :organization
    @response1 = @donor1.latest_response
    @response2 = @donor2.latest_response
    @project1  = Factory(:project, :data_response => @response1)
    @project2  = Factory(:project, :data_response => @response2)
  end

  describe "#linked?" do
    context "when not all in flows has parent project" do
      it "returns false" do
        @project.in_flows = [
            Factory.build(:funding_flow, :from => @donor1, :project_from => @project1),
            Factory.build(:funding_flow, :from => @donor2, :project_from => nil)]
        @project.linked?.should be_false
      end
    end

    context "when all in flows has parent project" do
      it "returns true" do
        @project.in_flows = [
            Factory.build(:funding_flow, :from => @donor1, :project_from => @project1),
            Factory.build(:funding_flow, :from => @donor2, :project_from => @project2)]
        @project.linked?.should be_true
      end
    end
  end

  describe "#validation_errors" do
    context "project has no error" do
      it "returns no response errors" do
        @activity = Factory(:activity, :data_response => @response, :project => @project)
        @split    = Factory(:implementer_split, :organization => @organization,
                            :activity => @activity, :budget => 10, :spend => 10)
        Factory(:funding_flow, :from => @organization,
                :project => @project, :project_from => @project, :budget => 10, :spend => 10)
        @project.validation_errors.should == []
      end
    end
  end

  describe "#matches_in_flow_amount?" do
    context "activity amounts and in flow amounts are equal" do
      it "returns true" do
        @activity = Factory(:activity, :data_response => @response, :project => @project)
        @split    = Factory(:implementer_split, :organization => @organization,
                            :activity => @activity, :budget => 1, :spend => 9)
        @activity2 = Factory(:activity, :data_response => @response, :project => @project)
        @split    = Factory(:implementer_split, :organization => @organization,
                            :activity => @activity2, :budget => 9, :spend => 1)
        @activity.reload; @activity.save # refresh cached amounts
        @activity2.reload; @activity2.save # refresh cached amounts
        @project.reload
        @project.in_flows = [Factory.build(:funding_flow, :from => @donor1, :budget => 3, :spend => 7),
                             Factory.build(:funding_flow, :from => @donor2, :budget => 7, :spend => 3)]
        @project.save!
        @project.matches_in_flow_amount?(:budget).should be_true
        @project.matches_in_flow_amount?(:spend).should be_true
      end
    end

    context "activity amounts and in flow amounts are not equal" do
      it "returns false" do
        @activity = Factory(:activity, :data_response => @response, :project => @project)
        @split    = Factory(:implementer_split, :organization => @organization,
                            :activity => @activity, :budget => 1, :spend => 9)
        @activity.save # refresh cached amounts
        Factory(:funding_flow, :from => @organization,
                :project => @project, :budget => 4, :spend => 4)
        @project.reload
        @project.matches_in_flow_amount?(:budget).should be_false
        @project.matches_in_flow_amount?(:spend).should be_false
      end
    end
  end
end
