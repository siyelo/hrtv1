require File.dirname(__FILE__) + '/../spec_helper'

include DelayedJobSpecHelper

describe Reports::FundingSource do
  def run_report
    report = Reports::FundingSource.new(@request)
    csv = report.csv
    table = []
    FasterCSV.parse(csv, :headers => true) { |row| table << row }
    return table
  end

  context "simple report" do
    before :each do
      basic_setup_funding_flow
      @donor = Factory(:organization)
      @organization = Factory(:organization)
      @request      = Factory(:data_request, :organization => @organization)
      @response     = @organization.latest_response
      @project      = Factory(:project, :data_response => @response)
      @project.in_flows = [Factory(:funding_flow, :project => @project,
                                   :from => @donor)]
      @response.state = 'accepted'; @response.save
    end

    it "should return a 1 funder report" do
      table = run_report
      table[0]['Funding Source'].should == @project.in_flows.first.from.name
      table[0]['Organization'].should == @organization.try(:name)
      table[0]['Project'].should == @project.try(:name)
      table[0]['Planned Disbursement'].should == "90.00"
      table[0]['Disbursement Received'].should == "100.00"
    end

    context "multiflow reports" do
      before :each do
        @donor1 = Factory(:organization, :name => "dony")
        @organization1 = Factory(:organization, :name => "orgy")
        @response1     = @organization1.latest_response
        @response1.state = 'accepted'; @response1.save
        @project1      = Factory(:project, :data_response => @response1, :name => "CoolProject")
        @project1.in_flows = [Factory(:funding_flow, :project => @project1,
                                      :from => @donor1, :spend => 99, :budget => 98)]
      end

      it "should properly convert currencies" do
        @currency = Factory(:currency, :conversion => 'RWF_TO_USD', :rate => 0.5)
        @project1.currency = "RWF"; @project1.save

        table = run_report
        table[0]['Funding Source'].should == @project.in_flows.first.from.name
        table[0]['Organization'].should == @organization.name
        table[0]['Project'].should == @project.name
        table[0]['Planned Disbursement'].should == "90.00"
        table[0]['Disbursement Received'].should == "100.00"

        table[1]['Funding Source'].should == @donor1.name
        table[1]['Organization'].should == "orgy"
        table[1]['Project'].should == "CoolProject"
        table[1]['Planned Disbursement'].should == "49.00"
        table[1]['Disbursement Received'].should == "49.50"
      end

      it "should return a 2 funder report" do
        table = run_report
        table[0]['Funding Source'].should == @project.in_flows.first.from.name
        table[0]['Organization'].should == @organization.name
        table[0]['Project'].should == @project.name
        table[0]['Planned Disbursement'].should == "90.00"
        table[0]['Disbursement Received'].should == "100.00"

        table[1]['Funding Source'].should == @donor1.name
        table[1]['Organization'].should == "orgy"
        table[1]['Project'].should == "CoolProject"
        table[1]['Planned Disbursement'].should == "98.00"
        table[1]['Disbursement Received'].should == "99.00"
      end
    end
  end
end

