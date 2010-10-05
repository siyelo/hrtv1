require File.dirname(__FILE__) + '/../../spec_helper'

describe Reports::ActivityReport do

  describe "add rows to csv" do
    it "should now display values when rows is empty array" do
      report = Reports::ActivityReport.new
      csv = FasterCSV.generate do |csv|
        csv << ['column1', 'column2']
        report.send(:add_rows_to_csv, [], csv)
      end
      csv.should == "column1,column2\n"
    end

    it "should display values when rows is array" do
      report = Reports::ActivityReport.new
      csv = FasterCSV.generate do |csv|
        csv << ['column1', 'column2']
        report.send(:add_rows_to_csv, [1, 2], csv)
      end
      csv.should == "column1,column2\n1,2\n"
    end

    it "should display values when rows are nested arrays" do
      report = Reports::ActivityReport.new
      csv = FasterCSV.generate do |csv|
        csv << ['column1', 'column2']
        report.send(:add_rows_to_csv, [[1, 2], [3, 4]], csv)
      end
      csv.should == "column1,column2\n1,2\n3,4\n"
    end

    it "should display values when rows are nested arrays with another level" do
      report = Reports::ActivityReport.new
      csv = FasterCSV.generate do |csv|
        csv << ['column1', 'column2']
        report.send(:add_rows_to_csv, [[[1, 2], [3, 4]], [[5, 6], [7, 8]]], csv)
      end
      csv.should == "column1,column2\n1,2\n3,4\n5,6\n7,8\n"
    end
  end
end
