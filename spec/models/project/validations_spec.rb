require File.dirname(__FILE__) + '/../../spec_helper'

describe Project, "Validations" do
  describe "#linked?" do
    before :each do
      @organization = Factory(:organization)
      request       = Factory(:data_request, :organization => @organization)
      @response     = @organization.latest_response
      @project      = Factory(:project, :data_response => @response)
    end

    context "when not all in flows has parent project" do
      it "returns false" do
        Factory(:funding_flow, :from => @organization, :to => @organization,
                :project => @project, :project_from => @project)
        Factory(:funding_flow, :from => @organization, :to => @organization,
                :project => @project, :project_from => nil)
        @project.linked?.should be_false
      end
    end

    context "when all in flows has parent project" do
      it "returns true" do
        Factory(:funding_flow, :from => @organization, :to => @organization,
                :project => @project, :project_from => @project)
        Factory(:funding_flow, :from => @organization, :to => @organization,
                :project => @project, :project_from => @project)
        @project.linked?.should be_true
      end
    end
  end

  describe "#validation_errors" do
    before :each do
      @organization = Factory(:organization)
      request       = Factory(:data_request, :organization => @organization)
      @response     = @organization.latest_response
      @project      = Factory(:project, :data_response => @response)
    end

    context "project has all errors" do
      it "returns 'Project is not currently linked.' error" do
        Factory(:funding_flow, :from => @organization, :to => @organization,
                :project => @project, :budget => 10, :spend => 10)
        @project.validation_errors.should include('Project is not currently linked.')
        @project.validation_errors.should include("Project Past Expenditure Total (USD 0) does not match the Funding Source Past Expenditure Total (USD 10). Please update Past Expenditures accordingly.")
        @project.validation_errors.should include("Project Current Budget Total (USD 0) does not match the Funding Source Current Budget Total (USD 10). Please update Current Budgets accordingly.")
      end
    end

    context "project has no error" do
      it "returns no response errors" do
        Factory(:activity, :data_response => @response, :project => @project,
                :budget => 10, :spend => 10)
        Factory(:funding_flow, :from => @organization, :to => @organization,
                :project => @project, :project_from => @project, :budget => 10, :spend => 10)
        @project.validation_errors.should == []
      end
    end
  end

  describe "#matches_in_flow_amount?" do
    before :each do
      @organization = Factory(:organization)
      request       = Factory(:data_request, :organization => @organization)
      @response     = @organization.latest_response
      @project      = Factory(:project, :data_response => @response)
    end

    context "activity amounts and in flow amounts are equal" do
      it "returns true" do
        Factory(:activity, :data_response => @response, :project => @project,
                :budget => 1, :spend => 9)
        Factory(:activity, :data_response => @response, :project => @project,
                :budget => 9, :spend => 1)
        Factory(:funding_flow, :from => @organization, :to => @organization,
                :project => @project, :budget => 3, :spend => 7)
        Factory(:funding_flow, :from => @organization, :to => @organization,
                :project => @project, :budget => 7, :spend => 3)
        @project.matches_in_flow_amount?(:budget).should be_true
        @project.matches_in_flow_amount?(:spend).should be_true
      end
    end

    context "activity amounts and in flow amounts are not equal" do
      it "returns false" do
        Factory(:activity, :data_response => @response, :project => @project,
                :budget => 5, :spend => 5)
        Factory(:funding_flow, :from => @organization, :to => @organization,
                :project => @project, :budget => 4, :spend => 4)
        @project.matches_in_flow_amount?(:budget).should be_false
        @project.matches_in_flow_amount?(:spend).should be_false
      end
    end
  end
end
