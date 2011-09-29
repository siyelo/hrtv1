require File.dirname(__FILE__) + '/../spec_helper'

describe Reports::ProjectsExport do
  describe "export projects and activities to xls" do
    it "should return xls with blank cells for repeated project & activity" do
      @organization  = Factory(:organization, :name => 'org1')
      @organization2 = Factory(:organization, :name => 'org2')
      @request       = Factory(:data_request, :organization => @organization)
      @response      = @organization.latest_response
      @project       = Factory(:project, :data_response => @response)
      @activity      = Factory(:activity, :data_response => @response,
                               :project => @project)
      # sub_activity   = Factory(:sub_activity, :activity => @activity,
                               # :data_response => @response, :provider => @organization)
      # sub_activity2  = Factory(:sub_activity, :activity => @activity,
                               # :data_response => @response, :provider => @organization2)
      @split = Factory(:implementer_split, :activity => @activity,
        :organization => @organization)
      @split2 = Factory(:implementer_split, :activity => @activity,
        :organization => @organization)

      @activity.save!

      xls = Reports::ProjectsExport.new(@response).to_xls
      rows = Spreadsheet.open(StringIO.new(xls)).worksheet(0)
      rows.row(0).should == Reports::ProjectsExport::FILE_UPLOAD_COLUMNS
      rows[1,0].should == @project.try(:name)
      rows[1,1].should == @project.try(:description)
      rows[1,2].should == @project.try(:start_date).to_s
      rows[1,3].should == @project.try(:end_date).to_s
      rows[1,4].should == @activity.name
      rows[1,5].should == @activity.description
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
