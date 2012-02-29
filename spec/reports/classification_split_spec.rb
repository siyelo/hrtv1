require File.dirname(__FILE__) + '/../spec_helper'

include DelayedJobSpecHelper

describe Reports::ClassificationSplit do
  def run_report(classification_type)
    report = Reports::ClassificationSplit.new(@request, :budget, classification_type.to_sym)
    csv = report.csv
    #File.open('debug.csv', 'w') { |f| f.puts report.csv }
    table = []
    FasterCSV.parse(csv, :headers => true) { |row| table << row }
    return table
  end

  before :each do
    @donor1        = Factory(:organization, :name => "donor1")
    @organization1 = Factory(:organization, :name => "organization1",
      :implementer_type => "Implementer")
    @request       = Factory(:data_request, :organization => @organization1)
    @response1     = @organization1.latest_response
    in_flows       = [Factory.build(:funding_flow, :from => @donor1,
                                    :budget => 50)]
    @project1      = Factory(:project, :data_response => @response1,
                             :name => 'project1',
                             :in_flows => in_flows)
  end

  context "budget" do
    [:purpose, :input, :location].each do |classification_type|
      context classification_type do
        before :each do
          @code1_name          = "#{classification_type}1"
          @code2_name          = "#{classification_type}2"
          code1               = Factory(classification_type,
                                 :short_display => @code1_name)
          code2               = Factory(classification_type,
                                 :short_display => @code2_name)
          @classification_name = classification_type.to_s.capitalize
          # implementer splits
          organization2 = Factory(:organization, :name => 'organization2')
          impl_splits = []
          impl_splits << Factory(:implementer_split,
            :organization => @organization1, :budget => 100)
          impl_splits << Factory(:implementer_split,
            :organization => organization2, :budget => 50)

          @activity1 = Factory(:activity, :project => @project1,
                              :name => '@activity1',
                              :description => '@activity1 descr',
                              :data_response => @response1,
                              :implementer_splits => impl_splits)

          # Classifications
          classifications = { code1.id => 25, code2.id => 75 }
          if classification_type == :purpose
            CodingBudget.update_classifications(@activity1, classifications)
          elsif classification_type == :input
            CodingBudgetCostCategorization.update_classifications(@activity1, classifications)
          elsif classification_type == :location
            CodingBudgetDistrict.update_classifications(@activity1, classifications)
          else
            raise "Invalid type #{classification_type}".to_yaml
          end

          run_delayed_jobs

          @response1.state = 'accepted'; @response1.save!

        end

        it "generates proper report" do
          table = run_report(classification_type)
          # row 1
          table[0]['Organization'].should == 'organization1'
          table[0]['Project'].should == 'project1'
          table[0]['Funding Source'].should == 'donor1'
          table[0]['Data Response ID'].should == @response1.id.to_s
          table[0]['Activity ID'].should == @activity1.id.to_s
          table[0]['Activity'].should == '@activity1'
          table[0]['Activity Descr'].should == '@activity1 descr'
          table[0]['Total Activity Budget ($)'].should == '150.00'
          table[0]['Implementer'].should == 'organization1'
          table[0]['Implementer Type'].should == 'Implementer'
          table[0]['Total Implementer Budget ($)'].should == '100.00'
          table[0]["#{@classification_name} Code"].should == @code1_name
          table[0]["#{@classification_name} Code Split (%)"].should == '25.0'
          table[0]["Implementer Budget by #{@classification_name} ($)"].should == '25.00'
          table[0]['Possible Double-Count?'].should == 'false'
          table[0]['Actual Double-Count?'].should == nil
          table[0]["#{@classification_name} Hierarchy"].should == @code1_name

          # row 2
          table[1]['Organization'].should == 'organization1'
          table[1]['Project'].should == 'project1'
          table[1]['Funding Source'].should == 'donor1'
          table[1]['Data Response ID'].should == @response1.id.to_s
          table[1]['Activity ID'].should == @activity1.id.to_s
          table[1]['Activity'].should == '@activity1'
          table[1]['Activity Descr'].should == '@activity1 descr'
          table[1]['Total Activity Budget ($)'].should == '150.00'
          table[1]['Implementer'].should == 'organization1'
          table[1]['Implementer Type'].should == 'Implementer'
          table[1]['Total Implementer Budget ($)'].should == '100.00'
          table[1]["#{@classification_name} Code"].should == @code2_name
          table[1]["#{@classification_name} Code Split (%)"].should == '75.0'
          table[1]["Implementer Budget by #{@classification_name} ($)"].should == '75.00'
          table[1]['Possible Double-Count?'].should == 'false'
          table[1]['Actual Double-Count?'].should == nil
          table[1]["#{@classification_name} Hierarchy"].should == @code2_name

          # row 3
          table[2]['Organization'].should == 'organization1'
          table[2]['Project'].should == 'project1'
          table[2]['Funding Source'].should == 'donor1'
          table[2]['Data Response ID'].should == @response1.id.to_s
          table[2]['Activity ID'].should == @activity1.id.to_s
          table[2]['Activity'].should == '@activity1'
          table[2]['Activity Descr'].should == '@activity1 descr'
          table[2]['Total Activity Budget ($)'].should == '150.00'
          table[2]['Implementer'].should == 'organization2'
          table[2]['Implementer Type'].should be_nil
          table[2]['Total Implementer Budget ($)'].should == '50.00'
          table[2]["#{@classification_name} Code"].should == @code1_name
          table[2]["#{@classification_name} Code Split (%)"].should == '25.0'
          table[2]["Implementer Budget by #{@classification_name} ($)"].should == '12.50'
          table[2]['Possible Double-Count?'].should == 'false'
          table[2]['Actual Double-Count?'].should == nil
          table[2]["#{@classification_name} Hierarchy"].should == @code1_name

          # row 4
          table[3]['Organization'].should == 'organization1'
          table[3]['Project'].should == 'project1'
          table[3]['Funding Source'].should == 'donor1'
          table[3]['Data Response ID'].should == @response1.id.to_s
          table[3]['Activity ID'].should == @activity1.id.to_s
          table[3]['Activity'].should == '@activity1'
          table[3]['Activity Descr'].should == '@activity1 descr'
          table[3]['Total Activity Budget ($)'].should == '150.00'
          table[3]['Implementer'].should == 'organization2'
          table[3]['Implementer Type'].should be_nil
          table[3]['Total Implementer Budget ($)'].should == '50.00'
          table[3]["#{@classification_name} Code"].should == @code2_name
          table[3]["#{@classification_name} Code Split (%)"].should == '75.0'
          table[3]["Implementer Budget by #{@classification_name} ($)"].should == '37.50'
          table[3]['Possible Double-Count?'].should == 'false'
          table[3]['Actual Double-Count?'].should == nil
          table[3]["#{@classification_name} Hierarchy"].should == @code2_name
        end

        it "does currency conversion to USD" do
          Money.default_bank.set_rate(:RWF, :USD, 0.1)
          @organization1.currency = 'RWF'
          @organization1.save!
          table = run_report(classification_type)
          table[0]['Organization'].should == 'organization1'
          table[0]['Project'].should == 'project1'
          table[0]['Funding Source'].should == 'donor1'
          table[0]['Data Response ID'].should == @response1.id.to_s
          table[0]['Activity ID'].should == @activity1.id.to_s
          table[0]['Activity'].should == '@activity1'
          table[0]['Activity Descr'].should == '@activity1 descr'
          table[0]['Total Activity Budget ($)'].should == '15.00'
          table[0]['Implementer'].should == 'organization1'
          table[0]['Implementer Type'].should == 'Implementer'
          table[0]['Total Implementer Budget ($)'].should == '10.00'
          table[0]["#{@classification_name} Code"].should == @code1_name
          table[0]["#{@classification_name} Code Split (%)"].should == '25.0'
          table[0]["Implementer Budget by #{@classification_name} ($)"].should == '2.50'
          table[0]['Possible Double-Count?'].should == 'false'
          table[0]['Actual Double-Count?'].should == nil
          table[0]["#{@classification_name} Hierarchy"].should == @code1_name
        end
      end
    end
  end
end
