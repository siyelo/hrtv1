require File.dirname(__FILE__) + '/../spec_helper'

include DelayedJobSpecHelper

describe Reports::FundingSourceSplit do
  def run_report(amount_type)
    report = Reports::FundingSourceSplit.new(@request, amount_type)
    csv = report.csv

    #File.open('debug.csv', 'w') { |f| f.puts report.csv }

    table = []
    FasterCSV.parse(csv, :headers => true) { |row| table << row }

    return table
  end


  [:budget, :spend].each do |amount_type|
    context "#{amount_type}" do
      before :each do
        @donor1        = Factory(:organization, :name => "donor1",
         :funder_type => "donor")
        @donor2        = Factory(:organization, :name => "donor2",
         :funder_type => "government")
        @organization1 = Factory(:organization, :name => "organization1",
         :implementer_type => "implementer")
        @request       = Factory(:data_request, :organization => @organization1)
        @response1     = @organization1.latest_response
        in_flow1       = Factory.build(:funding_flow, :from => @donor1,
                                       amount_type => 60)
        in_flow2       = Factory.build(:funding_flow, :from => @donor2,
                                       amount_type => 40)
        in_flows       = [in_flow1, in_flow2]
        @project1      = Factory(:project, :data_response => @response1,
                                 :name => 'project1',
                                 :in_flows => in_flows)
        impl_splits   = []
        organization2 = Factory(:organization, :name => 'organization2',
         :implementer_type => 'distributor')
        impl_splits << Factory(:implementer_split,
          :organization => @organization1, amount_type => 50)
        impl_splits << Factory(:implementer_split,
          :organization => organization2, amount_type => 50)

        @activity1 = Factory(:activity, :project => @project1,
                            :name => 'activity1',
                            :data_response => @response1,
                            :implementer_splits => impl_splits)

        @response1.state = 'accepted'; @response1.save!
      end

      it "generates proper report" do
        table = run_report(amount_type)
        amount_name = amount_type.to_s.capitalize

        # row 1
        table[0]['Organization'].should == 'organization1'
        table[0]['Project'].should == 'project1'
        table[0]['Data Response ID'].should == @response1.id.to_s
        table[0]['Activity ID'].should == @activity1.id.to_s
        table[0]['Activity'].should == 'activity1'
        table[0]["Total Activity #{amount_name} ($)"].should == '100.00'
        table[0]['Implementer'].should == 'organization1'
        table[0]['Implementer Type'].should == 'implementer'
        table[0]["Total Implementer #{amount_name} ($)"].should == '50.00'
        table[0]['Funding Source'].should == 'donor1'
        table[0]['Funder Type'].should == 'donor'
        table[0]["Total Funding Source #{amount_name} ($)"].should == '60.00'
        table[0]['Funding Source Ratio'].should == '0.6'
        table[0]["Implementer #{amount_name} by Funding Source"] == '30.00'
        table[0]['Possible Duplicate?'].should == 'false'
        table[0]['Actual Duplicate?'].should == nil

        # row 2
        table[1]['Organization'].should == 'organization1'
        table[1]['Project'].should == 'project1'
        table[1]['Data Response ID'].should == @response1.id.to_s
        table[1]['Activity ID'].should == @activity1.id.to_s
        table[1]['Activity'].should == 'activity1'
        table[1]["Total Activity #{amount_name} ($)"].should == '100.00'
        table[1]['Implementer'].should == 'organization1'
        table[1]['Implementer Type'].should == 'implementer'
        table[1]["Total Implementer #{amount_name} ($)"].should == '50.00'
        table[1]['Funding Source'].should == 'donor2'
        table[1]['Funder Type'].should == 'government'
        table[1]["Total Funding Source #{amount_name} ($)"].should == '40.00'
        table[1]['Funding Source Ratio'].should == '0.4'
        table[1]["Implementer #{amount_name} by Funding Source"] == '20.00'
        table[1]['Possible Duplicate?'].should == 'false'
        table[1]['Actual Duplicate?'].should == nil

        # row 3
        table[2]['Organization'].should == 'organization1'
        table[2]['Project'].should == 'project1'
        table[2]['Data Response ID'].should == @response1.id.to_s
        table[2]['Activity ID'].should == @activity1.id.to_s
        table[2]['Activity'].should == 'activity1'
        table[2]["Total Activity #{amount_name} ($)"].should == '100.00'
        table[2]['Implementer'].should == 'organization2'
        table[2]['Implementer Type'].should == 'distributor'
        table[2]["Total Implementer #{amount_name} ($)"].should == '50.00'
        table[2]['Funding Source'].should == 'donor1'
        table[2]['Funder Type'].should == 'donor'
        table[2]["Total Funding Source #{amount_name} ($)"].should == '60.00'
        table[2]['Funding Source Ratio'].should == '0.6'
        table[2]["Implementer #{amount_name} by Funding Source"] == '30.00'
        table[2]['Possible Duplicate?'].should == 'false'
        table[2]['Actual Duplicate?'].should == nil

        # row 4
        table[3]['Organization'].should == 'organization1'
        table[3]['Project'].should == 'project1'
        table[3]['Data Response ID'].should == @response1.id.to_s
        table[3]['Activity ID'].should == @activity1.id.to_s
        table[3]['Activity'].should == 'activity1'
        table[3]["Total Activity #{amount_name} ($)"].should == '100.00'
        table[3]['Implementer'].should == 'organization2'
        table[3]['Implementer Type'].should == 'distributor'
        table[3]["Total Implementer #{amount_name} ($)"].should == '50.00'
        table[3]['Funding Source'].should == 'donor2'
        table[3]['Funder Type'].should == 'government'
        table[3]["Total Funding Source #{amount_name} ($)"].should == '40.00'
        table[3]['Funding Source Ratio'].should == '0.4'
        table[3]["Implementer #{amount_name} by Funding Source"] == '20.00'
        table[3]['Possible Duplicate?'].should == 'false'
        table[3]['Actual Duplicate?'].should == nil
      end
    end
  end
end
