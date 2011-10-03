require File.dirname(__FILE__) + '/../spec_helper'

include DelayedJobSpecHelper

describe Reports::JawpReport do
  def setup_classified_data(response, splits)
    impl_splits = []
    splits.each do |split|
      impl_splits << Factory.build(:sub_activity, :data_response => response,
                      :provider => split[:organization],
                      :budget => split[:budget])
    end

    activity     = Factory.build(:activity, :data_response => response,
                     :implementer_splits => impl_splits,
                     :name => 'activity1')
    project      = Factory(:project, :data_response => response, :name => 'project1',
                     :activities => [activity],
                     :in_flows => [Factory.build(:funding_flow,
                                                 :from => @donor, :budget => 30)])

    CodingBudget.update_classifications(activity, { @code1.id => 50, @code2.id => 50})
    CodingBudgetCostCategorization.update_classifications(activity, { @code_cc.id => 100})

    run_delayed_jobs
  end

  before :each do
    @donor        = Factory(:organization, :name => "donor")
    @organization = Factory(:organization, :name => "self-implementer")
    @request      = Factory(:data_request, :organization => @organization)
    @response     = @organization.latest_response
    @code1    = Factory(:mtef_code, :short_display => 'mtef1')
    @code2    = Factory(:mtef_code, :short_display => 'mtef2')
    @code_cc  = Factory(:cost_category_code, :short_display => 'cost_category1')
  end

  it "produces correct values" do
    splits = [{:organization => @organization, :budget => 30}]
    setup_classified_data(@response, splits)
    report = Reports::JawpReport.new(:budget, Activity.only_simple)
    csv = report.csv

    #File.open('debug.csv', 'w') do |f|
      #f.puts report.csv
    #end

    table = []
    FasterCSV.parse(csv, :headers => true).each do |row|
      table << row
    end

    # row 1
    table[0]['Activity Name'].should == 'activity1'
    table[0]['Total Current Budget'].should == '30.0'
    table[0]['Converted Current Budget (USD)'] == '30.0'
    table[0]['Classified Current Budget'].should == '15.0'
    table[0]['Converted Classified Current Budget (USD)'].should == '15.0'
    table[0]['Classified Current Budget Percentage'].should == '0.5'
    table[0]['Classified Current Budget'].should == '15.0'
    table[0]['Code'].should == 'mtef1'
    table[0]['Input'].should == 'cost_category1'
    table[0]['Possible Duplicate?'].should == 'false'

    # row 2
    table[1]['Activity Name'].should == 'activity1'
    table[1]['Total Current Budget'].should == '30.0'
    table[1]['Converted Current Budget (USD)'] == '30.0'
    table[1]['Classified Current Budget'].should == '15.0'
    table[1]['Converted Classified Current Budget (USD)'].should == '15.0'
    table[1]['Classified Current Budget Percentage'].should == '0.5'
    table[1]['Classified Current Budget'].should == '15.0'
    table[1]['Code'].should == 'mtef2'
    table[1]['Input'].should == 'cost_category1'
    table[1]['Possible Duplicate?'].should == 'false'
  end

  context "when only 1 implementer for activity" do
    context "self implementer" do
      it "does not mark double count" do
        splits = [{:organization => @organization, :budget => 15}]
        setup_classified_data(@response, splits)

        organization2 = Factory(:organization, :name => "other-hrt-implementer")
        response2     = organization2.latest_response
        splits = [{:organization => organization2, :budget => 15}]
        setup_classified_data(response2, splits)

        report = Reports::JawpReport.new(:budget, Activity.only_simple)
        csv = report.csv

        table = []
        FasterCSV.parse(csv, :headers => true).each do |row|
          table << row
        end

        table[0]['Possible Duplicate?'].should == 'false'
        table[1]['Possible Duplicate?'].should == 'false'
        table[2]['Possible Duplicate?'].should == 'false'
        table[3]['Possible Duplicate?'].should == 'false'
      end
    end

    context "non-hrt implementer" do
      it "does not mark double count" do
        organization2 = Factory(:organization, :raw_type => 'Non-Reporting')
        # non-reporting organization has no response
        # so we don't need to setup any classified data for it
        splits = [{:organization => organization2, :budget => 30}]
        setup_classified_data(@response, splits)

        report = Reports::JawpReport.new(:budget, Activity.only_simple)
        csv = report.csv

        table = []
        FasterCSV.parse(csv, :headers => true).each do |row|
          table << row
        end

        table[0]['Possible Duplicate?'].should == 'false'
        table[1]['Possible Duplicate?'].should == 'false'
      end
    end

    context "another hrt implementer" do
      it "marks double counting" do
        organization2 = Factory(:organization, :name => "other-hrt-implementer")
        response2     = organization2.latest_response

        # org2 is implementer or org1
        splits = [{:organization => organization2, :budget => 15}]
        setup_classified_data(@response, splits)

        # org2 is self implementer
        splits = [{:organization => organization2, :budget => 15}]
        setup_classified_data(response2, splits)

        report = Reports::JawpReport.new(:budget, Activity.only_simple)
        csv = report.csv

        table = []
        FasterCSV.parse(csv, :headers => true).each do |row|
          table << row
        end

        table[0]['Possible Duplicate?'].should == 'true'
        table[1]['Possible Duplicate?'].should == 'true'
        table[2]['Possible Duplicate?'].should == 'false'
        table[3]['Possible Duplicate?'].should == 'false'
      end
    end
  end

  context "when 2 implementers for activity" do
    context "another hrt implementer" do
      it "marks double counting" do
        organization2 = Factory(:organization, :name => "other-hrt-implementer")
        response2     = organization2.latest_response

        # org2 is implementer or org1
        splits = [{:organization => @organization, :budget => 15},
                  {:organization => organization2, :budget => 15}]
        setup_classified_data(@response, splits)

        # org2 is self implementer
        splits = [{:organization => organization2, :budget => 15}]
        setup_classified_data(response2, splits)

        report = Reports::JawpReport.new(:budget, Activity.only_simple)
        csv = report.csv

        table = []
        FasterCSV.parse(csv, :headers => true).each do |row|
          table << row
        end

        table[0]['Possible Duplicate?'].should == 'true'
        table[1]['Possible Duplicate?'].should == 'true'
        table[2]['Possible Duplicate?'].should == 'false'
        table[3]['Possible Duplicate?'].should == 'false'
      end
    end
  end
end
