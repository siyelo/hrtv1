require File.dirname(__FILE__) + '/../spec_helper'

include DelayedJobSpecHelper

describe Reports::JawpReport do
  before :each do
    @donor         = Factory(:organization, :name => "donor")
    @organization1 = Factory(:organization, :name => "organization1")
    @request       = Factory(:data_request, :organization => @organization1)
    @response1     = @organization1.latest_response
    @project1      = Factory(:project, :data_response => @response1, :currency => 'USD')

    @purpose1      = Factory(:mtef_code, :short_display => 'purpose1')
    @purpose2      = Factory(:mtef_code, :short_display => 'purpose2')
    @input1        = Factory(:cost_category_code, :short_display => 'input1')
    @input2        = Factory(:cost_category_code, :short_display => 'input2')
    @location1     = Factory(:location, :short_display => 'location1')
    @location2     = Factory(:location, :short_display => 'location2')
  end

  context "2 of each: purposes, inputs, locations, implementer splits" do
    it "returns proper Dynamic Query report" do
      organization2 = Factory(:organization, :name => "organization2")

      # implementer splits
      impl_splits = []
      impl_splits << Factory(:implementer_split, :activity => @activity1,
        :organization => @organization1, :budget => 100)
      impl_splits << Factory(:implementer_split, :activity => @activity1,
        :organization => organization2, :budget => 100)

      activity1 = Factory.build(:activity,
        :implementer_splits => impl_splits, :name => 'activity1',
        :data_response => @response1)

      project1  = Factory(:project, :data_response => @response1,
        :name => 'project1', :activities => [activity1], :in_flows => [
        Factory.build(:funding_flow, :from => @donor, :budget => 200)])

      # classifications
      CodingBudget.update_classifications(activity1,
        { @purpose1.id => 50, @purpose2.id => 50})
      CodingBudgetCostCategorization.update_classifications(activity1,
        { @input1.id => 50, @input2.id => 50} )
      CodingBudgetDistrict.update_classifications(activity1,
        { @location1.id => 50, @location2.id => 50} )

      run_delayed_jobs

      # accept both responses
      @response1.state = 'accepted'; @response1.save!

      report = Reports::JawpReport.new(@request, :budget)
      csv = report.csv

      #File.open('debug.csv', 'w') { |f| f.puts report.csv }

      table = []
      FasterCSV.parse(csv, :headers => true).each { |row| table << row }

      # row 1
      table[0]['Organization'].should == 'organization1'
      table[0]['Project'].should == 'project1'
      table[0]['Activity'].should == 'activity1'
      table[0]['Currency'].should == 'USD'

      15.times do |i|
        table[i]['Total Current Budget'].should == '200.0'
        table[i]['Converted Current Budget (USD)'].should == '200.0'
        table[i]['Classified Current Budget'].should == '12.5'
        table[i]['Classified Current Budget Ratio'].should == '0.0625'
        table[i]['Converted Classified Current Budget (USD)'].should == '12.5'
        table[i]['Possible Duplicate?'].should == 'false'
      end
    end
  end

  context "1 purpose, 1 inputs, 1 locations and no implementer_splits" do
    it "returns proper Dynamic Query report" do
      activity1 = Factory.build(:activity, :name => 'activity1',
        :data_response => @response1)

      project1  = Factory(:project, :data_response => @response1,
        :name => 'project1', :activities => [activity1], :in_flows => [
        Factory.build(:funding_flow, :from => @donor, :budget => 200)])

      # classifications
      CodingBudget.update_classifications(activity1,
        { @purpose1.id => 100})
      CodingBudgetCostCategorization.update_classifications(activity1,
        { @input1.id => 100} )
      CodingBudgetDistrict.update_classifications(activity1,
        { @location1.id => 100} )

      run_delayed_jobs

      # accept both responses
      @response1.state = 'accepted'; @response1.save!

      report = Reports::JawpReport.new(@request, :budget)
      csv = report.csv

      #File.open('debug.csv', 'w') { |f| f.puts report.csv }

      table = []
      FasterCSV.parse(csv, :headers => true).each { |row| table << row }

      #row 1
      table[0]['Organization'].should == 'organization1'
      table[0]['Project'].should == 'project1'
      table[0]['Activity'].should == 'activity1'
      table[0]['Currency'].should == 'USD'

      table[0]['Total Current Budget'].should == '0.0'
      table[0]['Converted Current Budget (USD)'].should == '0.0'
      table[0]['Classified Current Budget'].should == '0.0'
      table[0]['Classified Current Budget Ratio'].should == '0'
      table[0]['Converted Classified Current Budget (USD)'].should == '0.0'
      table[0]['Possible Duplicate?'].should == 'false'
      table[0]['Implementer'].should == nil
      table[0]['Purpose'].should == 'purpose1'
      table[0]['Input'].should == 'input1'
      table[0]['Location'].should == 'location1'
    end
  end

  context "1 purpose, 1 inputs, 1 implementer_splits and no locations" do
    it "returns proper Dynamic Query report" do
      impl_splits = []
      impl_splits << Factory(:implementer_split, :activity => @activity1,
        :organization => @organization1, :budget => 200)

      activity1 = Factory.build(:activity,
        :implementer_splits => impl_splits, :name => 'activity1',
        :data_response => @response1)

      project1  = Factory(:project, :data_response => @response1,
        :name => 'project1', :activities => [activity1], :in_flows => [
        Factory.build(:funding_flow, :from => @donor, :budget => 200)])

      # classifications
      CodingBudget.update_classifications(activity1,
        { @purpose1.id => 100})
      CodingBudgetCostCategorization.update_classifications(activity1,
        { @input1.id => 100} )

      run_delayed_jobs

      # accept both responses
      @response1.state = 'accepted'; @response1.save!

      report = Reports::JawpReport.new(@request, :budget)
      csv = report.csv

      #File.open('debug.csv', 'w') { |f| f.puts report.csv }

      table = []
      FasterCSV.parse(csv, :headers => true).each { |row| table << row }

      #row 1
      table[0]['Organization'].should == 'organization1'
      table[0]['Project'].should == 'project1'
      table[0]['Activity'].should == 'activity1'
      table[0]['Currency'].should == 'USD'

      table[0]['Total Current Budget'].should == '200.0'
      table[0]['Converted Current Budget (USD)'].should == '200.0'
      table[0]['Classified Current Budget'].should == '200.0'
      table[0]['Classified Current Budget Ratio'].should == '1.0'
      table[0]['Converted Classified Current Budget (USD)'].should == '200.0'
      table[0]['Possible Duplicate?'].should == 'false'
      table[0]['Implementer'].should == 'organization1'
      table[0]['Purpose'].should == 'purpose1'
      table[0]['Input'].should == 'input1'
      table[0]['Location'].should == nil
    end
  end

  context "1 inputs, 1 location, 1 implementer_splits and no purposes" do
    it "returns proper Dynamic Query report" do
      impl_splits = []
      impl_splits << Factory(:implementer_split, :activity => @activity1,
        :organization => @organization1, :budget => 200)

      activity1 = Factory.build(:activity,
        :implementer_splits => impl_splits, :name => 'activity1',
        :data_response => @response1)

      project1  = Factory(:project, :data_response => @response1,
        :name => 'project1', :activities => [activity1], :in_flows => [
        Factory.build(:funding_flow, :from => @donor, :budget => 200)])

      # classifications
      CodingBudgetCostCategorization.update_classifications(activity1,
        { @input1.id => 100} )
      CodingBudgetDistrict.update_classifications(activity1,
        { @location1.id => 100} )

      run_delayed_jobs

      # accept both responses
      @response1.state = 'accepted'; @response1.save!

      report = Reports::JawpReport.new(@request, :budget)
      csv = report.csv

      #File.open('debug.csv', 'w') { |f| f.puts report.csv }

      table = []
      FasterCSV.parse(csv, :headers => true).each { |row| table << row }

      #row 1
      table[0]['Organization'].should == 'organization1'
      table[0]['Project'].should == 'project1'
      table[0]['Activity'].should == 'activity1'
      table[0]['Currency'].should == 'USD'

      table[0]['Total Current Budget'].should == '200.0'
      table[0]['Converted Current Budget (USD)'].should == '200.0'
      table[0]['Classified Current Budget'].should == '200.0'
      table[0]['Classified Current Budget Ratio'].should == '1.0'
      table[0]['Converted Classified Current Budget (USD)'].should == '200.0'
      table[0]['Possible Duplicate?'].should == 'false'
      table[0]['Implementer'].should == 'organization1'
      table[0]['Purpose'].should == nil
      table[0]['Input'].should == 'input1'
      table[0]['Location'].should == 'location1'
    end
  end

  context "1 purpose, 1 location, 1 implementer_splits and no inputs" do
    it "returns proper Dynamic Query report" do
      impl_splits = []
      impl_splits << Factory(:implementer_split, :activity => @activity1,
        :organization => @organization1, :budget => 200)

      activity1 = Factory.build(:activity,
        :implementer_splits => impl_splits, :name => 'activity1',
        :data_response => @response1)

      project1  = Factory(:project, :data_response => @response1,
        :name => 'project1', :activities => [activity1], :in_flows => [
        Factory.build(:funding_flow, :from => @donor, :budget => 200)])

      # classifications
      CodingBudget.update_classifications(activity1,
        { @purpose1.id => 100})
      CodingBudgetDistrict.update_classifications(activity1,
        { @location1.id => 100} )

      run_delayed_jobs

      # accept both responses
      @response1.state = 'accepted'; @response1.save!

      report = Reports::JawpReport.new(@request, :budget)
      csv = report.csv

      #File.open('debug.csv', 'w') { |f| f.puts report.csv }

      table = []
      FasterCSV.parse(csv, :headers => true).each { |row| table << row }

      #row 1
      table[0]['Organization'].should == 'organization1'
      table[0]['Project'].should == 'project1'
      table[0]['Activity'].should == 'activity1'
      table[0]['Currency'].should == 'USD'

      table[0]['Total Current Budget'].should == '200.0'
      table[0]['Converted Current Budget (USD)'].should == '200.0'
      table[0]['Classified Current Budget'].should == '200.0'
      table[0]['Classified Current Budget Ratio'].should == '1.0'
      table[0]['Converted Classified Current Budget (USD)'].should == '200.0'
      table[0]['Possible Duplicate?'].should == 'false'
      table[0]['Implementer'].should == 'organization1'
      table[0]['Purpose'].should == 'purpose1'
      table[0]['Input'].should == nil
      table[0]['Location'].should == 'location1'
    end
  end
end
