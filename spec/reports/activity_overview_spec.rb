require File.dirname(__FILE__) + '/../spec_helper'

describe Reports::ActivityOverview do
  before :each do
    @donor1        = Factory(:organization, :name => "donor1")
    @organization1 = Factory(:organization, :name => "organization1")
    @request       = Factory(:data_request, :organization => @organization1)
    @response1     = @organization1.latest_response
  end

  context "1 funding source and 1 implementer" do
    it "returns proper format" do
      in_flow        = Factory.build(:funding_flow, :from => @donor1,
                                     :budget => 200, :spend => 100)
      @project1      = Factory(:project, :data_response => @response1,
                               :name => 'project1', :in_flows => [in_flow])

      @activity1     = Factory(:activity, :project => @project1,
                               :name => 'activity1',
                               :data_response => @response1)
      Factory(:implementer_split, :activity => @activity1,
              :organization => @organization1,
              :budget => 200, :spend => 100)

      @response1.state = 'accepted'; @response1.save!
      report = Reports::ActivityOverview.new(@request)
      csv = report.csv

      #File.open('debug.csv', 'w') { |f| f.puts report.csv }

      table = []
      FasterCSV.parse(csv, :headers => true) { |row| table << row }

      # row 1
      table[0]['Organization'].should == 'organization1'
      table[0]['Project'].should == 'project1'
      table[0]['Activity'].should == 'activity1'
      table[0]['Funding Source'].should == 'donor1'
      table[0]['Implementer'].should == 'organization1'
      table[0]['Expenditure ($)'].should == '100.0'
      table[0]['Budget ($)'].should == '200.0'
      table[0]['Possible Duplicate?'].should == 'false'
      table[0]['Actual Duplicate?'].should == ''
    end
  end

  context "1 funding sources and 2 implementers" do
    it "returns proper format" do
      in_flow        = Factory.build(:funding_flow, :from => @donor1,
                                     :budget => 200, :spend => 100)
      @project1      = Factory(:project, :data_response => @response1,
                               :name => 'project1', :in_flows => [in_flow])

      @activity1     = Factory(:activity, :project => @project1,
                               :name => 'activity1',
                               :data_response => @response1)
      Factory(:implementer_split, :activity => @activity1,
              :organization => @organization1,
              :budget => 100, :spend => 50)

      # make duplicate implemetner split
      # NOTE: figure out algorithm for checking
      # not only project, but we need to see if
      # to flow of money is entered
      @organization2 = Factory(:organization, :name => "organization2")
      @response2     = @organization2.latest_response
      in_flow        = Factory.build(:funding_flow, :from => @organization1,
                                     :budget => 100, :spend => 50)
      @project2      = Factory(:project, :data_response => @response2,
                               :name => 'project1', :in_flows => [in_flow])

      Factory(:implementer_split, :activity => @activity1,
              :organization => @organization2,
              :budget => 100, :spend => 50)

      @response1.state = 'accepted'; @response1.save!
      report = Reports::ActivityOverview.new(@request)
      csv = report.csv

      #File.open('debug.csv', 'w') { |f| f.puts report.csv }

      table = []
      FasterCSV.parse(csv, :headers => true) { |row| table << row }

      # row 1
      table[0]['Organization'].should == 'organization1'
      table[0]['Project'].should == 'project1'
      table[0]['Activity'].should == 'activity1'
      table[0]['Funding Source'].should == 'donor1'
      table[0]['Implementer'].should == 'organization1'
      table[0]['Expenditure ($)'].should == '50.0'
      table[0]['Budget ($)'].should == '100.0'
      table[0]['Possible Duplicate?'].should == 'false'
      table[0]['Actual Duplicate?'].should == ''

      # row 2
      table[1]['Organization'].should == 'organization1'
      table[1]['Project'].should == 'project1'
      table[1]['Activity'].should == 'activity1'
      table[1]['Funding Source'].should == 'donor1'
      table[1]['Implementer'].should == 'organization2'
      table[1]['Expenditure ($)'].should == '50.0'
      table[1]['Budget ($)'].should == '100.0'
      table[1]['Possible Duplicate?'].should == 'true'
      table[1]['Actual Duplicate?'].should == ''
    end
  end

  context "2 funding sources and 2 implementers" do
    it "returns proper format" do
      @donor2        = Factory(:organization, :name => "donor2")
      in_flow1        = Factory.build(:funding_flow, :from => @donor1,
                                      :budget => 100, :spend => 50)
      in_flow2        = Factory.build(:funding_flow, :from => @donor2,
                                      :budget => 100, :spend => 50)
      @project1      = Factory(:project, :data_response => @response1,
                               :name => 'project1', :in_flows => [in_flow1, in_flow2])

      @activity1     = Factory(:activity, :project => @project1,
                               :name => 'activity1',
                               :data_response => @response1)
      Factory(:implementer_split, :activity => @activity1,
              :organization => @organization1,
              :budget => 100, :spend => 50)

      # make duplicate implemetner split
      # NOTE: figure out algorithm for checking
      # not only project, but we need to see if
      # to flow of money is entered
      @organization2 = Factory(:organization, :name => "organization2")
      @response2     = @organization2.latest_response
      in_flow        = Factory.build(:funding_flow, :from => @organization1,
                                     :budget => 100, :spend => 50)
      @project2      = Factory(:project, :data_response => @response2,
                               :name => 'project1', :in_flows => [in_flow])

      Factory(:implementer_split, :activity => @activity1,
              :organization => @organization2,
              :budget => 100, :spend => 50)

      @response1.state = 'accepted'; @response1.save!
      report = Reports::ActivityOverview.new(@request)
      csv = report.csv

      #File.open('debug.csv', 'w') { |f| f.puts report.csv }

      table = []
      FasterCSV.parse(csv, :headers => true) { |row| table << row }

      # row 1
      table[0]['Organization'].should == 'organization1'
      table[0]['Project'].should == 'project1'
      table[0]['Activity'].should == 'activity1'
      table[0]['Funding Source'].should == 'donor1, donor2'
      table[0]['Implementer'].should == 'organization1'
      table[0]['Expenditure ($)'].should == '50.0'
      table[0]['Budget ($)'].should == '100.0'
      table[0]['Possible Duplicate?'].should == 'false'
      table[0]['Actual Duplicate?'].should == ''

      # row 2
      table[1]['Organization'].should == 'organization1'
      table[1]['Project'].should == 'project1'
      table[1]['Activity'].should == 'activity1'
      table[1]['Funding Source'].should == 'donor1, donor2'
      table[1]['Implementer'].should == 'organization2'
      table[1]['Expenditure ($)'].should == '50.0'
      table[1]['Budget ($)'].should == '100.0'
      table[1]['Possible Duplicate?'].should == 'true'
      table[1]['Actual Duplicate?'].should == ''
    end
  end
end
