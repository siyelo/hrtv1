require File.dirname(__FILE__) + '/../../spec_helper'

describe Reports::ProjectsExport do
  describe "export projects and activities to xls" do
    it "should return xls with blank cells for repeated project & activity" do
      basic_setup_activity
      sub_activity = Factory(:sub_activity, :activity => @activity, :data_response => @response)
      sub_activity2 = Factory(:sub_activity, :activity => @activity, :data_response => @response)
      @activity.reload; @activity.save!

      xls = Reports::ProjectsExport.new(@response).to_xls
      rows = Spreadsheet.open(StringIO.new(xls)).worksheet(0)
      rows.row(0).should == Project::FILE_UPLOAD_COLUMNS
      rows[1,0].should == sub_activity.activity.project.try(:name)
      rows[1,1].should == sub_activity.activity.project.try(:description)
      rows[1,2].should == sub_activity.activity.project.try(:start_date).to_s
      rows[1,3].should == sub_activity.activity.project.try(:end_date).to_s
      rows[1,4].should == sub_activity.activity.name
      rows[1,5].should == sub_activity.activity.description
      rows[1,6].should == sub_activity.id
      rows[1,7].should == sub_activity.provider.try(:name)
      rows[1,8].should == sub_activity.spend.to_f
      rows[1,9].should == sub_activity.budget.to_f

      rows[2,0].should == nil
      rows[2,1].should == nil
      rows[2,2].should == nil
      rows[2,3].should == nil
      rows[2,4].should == nil
      rows[2,5].should == nil
      rows[2,6].should == sub_activity2.id
      rows[2,7].should == sub_activity2.provider.try(:name)
      rows[2,8].should == sub_activity2.spend.to_f
      rows[2,9].should == sub_activity2.budget.to_f
    end

    it "should return import template" do
      xls = Reports::ProjectsExport.template
      rows = Spreadsheet.open(StringIO.new(xls)).worksheet(0)
    end
  end



end