require File.dirname(__FILE__) + '/../spec_helper'

include DelayedJobSpecHelper

describe Reports::Beneficiaries do
  def run_report(request, amount_type)
    report = Reports::Beneficiaries.new(request, amount_type)
    csv = report.csv

    #File.open('debug.csv', 'w') { |f| f.puts report.csv }

    table = []
    FasterCSV.parse(csv, :headers => true) { |row| table << row }

    return table
  end


  [:budget, :spend].each do |amount_type|
    context "#{amount_type}" do
      before :each do
        @donor1        = Factory(:organization, :name => "donor1")
        @donor2        = Factory(:organization, :name => "donor2")
        @organization1 = Factory(:organization, :name => "organization1",
                                 :implementer_type => "Implementer")
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
        organization2 = Factory(:organization, :name => 'organization2')
        impl_splits << Factory(:implementer_split,
          :organization => @organization1, amount_type => 50)
        impl_splits << Factory(:implementer_split,
          :organization => organization2, amount_type => 50)

        @activity1 = Factory(:activity, :project => @project1,
                            :name => 'activity1',
                            :data_response => @response1,
                            :implementer_splits => impl_splits)

        beneficiary1 = Factory(:beneficiary, :short_display => 'beneficiary1')
        beneficiary2 = Factory(:beneficiary, :short_display => 'beneficiary2')
        @activity1.beneficiaries << [beneficiary1, beneficiary2]
        @response1.state = 'accepted'; @response1.save!
      end

      it "generates proper report" do
        table = run_report(@request, amount_type)
        amount_name = amount_type.to_s.capitalize

        # row 1
        table[0]['Organization'].should == 'organization1'
        table[0]['Project'].should == 'project1'
        table[0]['Funding Source'].should == 'donor1 | donor2'
        table[0]['Activity'].should == 'activity1'
        table[0]['Activity ID'].should == @activity1.id.to_s
        table[0]["Total Activity #{amount_name} ($)"].should == '100.00'
        table[0]['Implementer'].should == 'organization1'
        table[0]['Implementer Type'].should == 'Implementer'
        table[0]["Total Implementer #{amount_name} ($)"].should == '25.00'
        table[0]['Activity Beneficiary'].should == 'beneficiary1'
        table[0]['Possible Double-Count?'].should == 'false'
        table[0]['Actual Double-Count?'].should == nil

        # row 2
        table[1]['Organization'].should == 'organization1'
        table[1]['Project'].should == 'project1'
        table[1]['Funding Source'].should == 'donor1 | donor2'
        table[1]['Activity'].should == 'activity1'
        table[1]['Activity ID'].should == @activity1.id.to_s
        table[1]["Total Activity #{amount_name} ($)"].should == '100.00'
        table[1]['Implementer'].should == 'organization1'
        table[1]['Implementer Type'].should == 'Implementer'
        table[1]["Total Implementer #{amount_name} ($)"].should == '25.00'
        table[1]['Activity Beneficiary'].should == 'beneficiary2'
        table[1]['Possible Double-Count?'].should == 'false'
        table[1]['Actual Double-Count?'].should == nil

        # row 3
        table[2]['Organization'].should == 'organization1'
        table[2]['Project'].should == 'project1'
        table[2]['Funding Source'].should == 'donor1 | donor2'
        table[2]['Activity'].should == 'activity1'
        table[2]['Activity ID'].should == @activity1.id.to_s
        table[2]["Total Activity #{amount_name} ($)"].should == '100.00'
        table[2]['Implementer'].should == 'organization2'
        table[2]['Implementer Type'].should be_nil
        table[2]["Total Implementer #{amount_name} ($)"].should == '25.00'
        table[2]['Activity Beneficiary'].should == 'beneficiary1'
        table[2]['Possible Double-Count?'].should == 'false'
        table[2]['Actual Double-Count?'].should == nil

        # row 4
        table[3]['Organization'].should == 'organization1'
        table[3]['Project'].should == 'project1'
        table[3]['Funding Source'].should == 'donor1 | donor2'
        table[3]['Activity'].should == 'activity1'
        table[3]['Activity ID'].should == @activity1.id.to_s
        table[3]["Total Activity #{amount_name} ($)"].should == '100.00'
        table[3]['Implementer'].should == 'organization2'
        table[3]['Implementer Type'].should be_nil
        table[3]["Total Implementer #{amount_name} ($)"].should == '25.00'
        table[3]['Activity Beneficiary'].should == 'beneficiary2'
        table[3]['Possible Double-Count?'].should == 'false'
        table[3]['Actual Double-Count?'].should == nil
      end
    end
  end
end
