require File.dirname(__FILE__) + '/../spec_helper'

include DelayedJobSpecHelper

describe Reports::ClassificationSplit do
  before :each do
    @donor1        = Factory(:organization, :name => "donor1")
    @organization1 = Factory(:organization, :name => "organization1")
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
        it "generates proper report" do
          code1_name          = "#{classification_type}1"
          code2_name          = "#{classification_type}2"
          code1               = Factory(classification_type,
                                 :short_display => code1_name)
          code2               = Factory(classification_type,
                                 :short_display => code2_name)
          classification_name = classification_type.to_s.capitalize
          # implementer splits
          organization2 = Factory(:organization, :name => 'organization2')
          impl_splits = []
          impl_splits << Factory(:implementer_split,
            :organization => @organization1, :budget => 100)
          impl_splits << Factory(:implementer_split,
            :organization => organization2, :budget => 50)

          activity1 = Factory(:activity, :project => @project1,
                              :name => 'activity1',
                              :data_response => @response1,
                              :implementer_splits => impl_splits)

          # Classifications
          classifications = { code1.id => 25, code2.id => 75 }
          if classification_type == :purpose
            CodingBudget.update_classifications(activity1, classifications)
          elsif classification_type == :input
            CodingBudgetCostCategorization.update_classifications(activity1, classifications)
          elsif classification_type == :location
            CodingBudgetDistrict.update_classifications(activity1, classifications)
          else
            raise "Invalid type #{classification_type}".to_yaml
          end

          run_delayed_jobs

          @response1.state = 'accepted'; @response1.save!
          report = Reports::ClassificationSplit.new(@request, :budget, classification_type.to_sym)
          csv = report.csv

          #File.open('debug.csv', 'w') { |f| f.puts report.csv }

          table = []
          FasterCSV.parse(csv, :headers => true) { |row| table << row }

          # row 1
          table[0]['Organization'].should == 'organization1'
          table[0]['Project'].should == 'project1'
          table[0]['Funding Source'].should == 'donor1'
          table[0]['Data Response ID'].should == @response1.id.to_s
          table[0]['Activity ID'].should == activity1.id.to_s
          table[0]['Activity'].should == 'activity1'
          table[0]['Total Activity Budget'].should == '150.0'
          table[0]['Implementer'].should == 'organization1'
          table[0]['Total Implementer Budget'].should == '100.0'
          table[0]["#{classification_name} Code"].should == code1_name
          table[0]["#{classification_name} Code Split"].should == '25.0'
          table[0]["Implementer Budget by #{classification_name}"].should == '25.0'
          table[0]['Possible Duplicate?'].should == 'false'
          table[0]['Actual Duplicate?'].should == 'false'
          table[0]["#{classification_name} Hierarchy"].should == code1_name

          # row 2
          table[1]['Organization'].should == 'organization1'
          table[1]['Project'].should == 'project1'
          table[1]['Funding Source'].should == 'donor1'
          table[1]['Data Response ID'].should == @response1.id.to_s
          table[1]['Activity ID'].should == activity1.id.to_s
          table[1]['Activity'].should == 'activity1'
          table[1]['Total Activity Budget'].should == '150.0'
          table[1]['Implementer'].should == 'organization1'
          table[1]['Total Implementer Budget'].should == '100.0'
          table[1]["#{classification_name} Code"].should == code2_name
          table[1]["#{classification_name} Code Split"].should == '75.0'
          table[1]["Implementer Budget by #{classification_name}"].should == '75.0'
          table[1]['Possible Duplicate?'].should == 'false'
          table[1]['Actual Duplicate?'].should == 'false'
          table[1]["#{classification_name} Hierarchy"].should == code2_name

          # row 3
          table[2]['Organization'].should == 'organization1'
          table[2]['Project'].should == 'project1'
          table[2]['Funding Source'].should == 'donor1'
          table[2]['Data Response ID'].should == @response1.id.to_s
          table[2]['Activity ID'].should == activity1.id.to_s
          table[2]['Activity'].should == 'activity1'
          table[2]['Total Activity Budget'].should == '150.0'
          table[2]['Implementer'].should == 'organization2'
          table[2]['Total Implementer Budget'].should == '50.0'
          table[2]["#{classification_name} Code"].should == code1_name
          table[2]["#{classification_name} Code Split"].should == '25.0'
          table[2]["Implementer Budget by #{classification_name}"].should == '12.5'
          table[2]['Possible Duplicate?'].should == 'false'
          table[2]['Actual Duplicate?'].should == 'false'
          table[2]["#{classification_name} Hierarchy"].should == code1_name

          # row 4
          table[3]['Organization'].should == 'organization1'
          table[3]['Project'].should == 'project1'
          table[3]['Funding Source'].should == 'donor1'
          table[3]['Data Response ID'].should == @response1.id.to_s
          table[3]['Activity ID'].should == activity1.id.to_s
          table[3]['Activity'].should == 'activity1'
          table[3]['Total Activity Budget'].should == '150.0'
          table[3]['Implementer'].should == 'organization2'
          table[3]['Total Implementer Budget'].should == '50.0'
          table[3]["#{classification_name} Code"].should == code2_name
          table[3]["#{classification_name} Code Split"].should == '75.0'
          table[3]["Implementer Budget by #{classification_name}"].should == '37.5'
          table[3]['Possible Duplicate?'].should == 'false'
          table[3]['Actual Duplicate?'].should == 'false'
          table[3]["#{classification_name} Hierarchy"].should == code2_name
        end
      end
    end

    context "input" do
      before :each do
      end
    end

    context "location" do
      before :each do
      end
    end
  end

  context "spend" do
    context "purpose" do
      before :each do
      end
    end

    context "input" do
      before :each do
      end
    end

    context "location" do
      before :each do
      end
    end
  end
end
