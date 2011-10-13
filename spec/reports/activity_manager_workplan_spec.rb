require File.dirname(__FILE__) + '/../spec_helper'

describe Reports::ActivityManagerWorkplan do
  describe "export projects and activities to xls" do
    it "should return xls with blank cells for repeated project & activity" do
      @organization  = Factory(:organization, :name => 'org1')
      @organization2 = Factory(:organization, :name => 'org2')
      @organization3 = Factory(:organization, :name => 'org3')
      @request       = Factory(:data_request, :organization => @organization)
      @response      = @organization.latest_response
      @response2     = @organization2.latest_response
      @user          = Factory.create(:activity_manager, :organization => @organization)
      @user.organizations << @organization2
      @user.organizations << @organization3
      @project       = Factory(:project, :data_response => @response2)
      @activity      = Factory(:activity, :data_response => @response2,
                               :project => @project)
      split          = Factory(:implementer_split, :activity => @activity,
                               :budget => 100, :spend => 200, :organization => @organization)
      @activity.reload
      @activity.save!

      @activity2     = Factory(:activity, :data_response => @response2,
                               :project => @project)
      split2         = Factory(:implementer_split, :activity => @activity2,
                               :budget => 200, :spend => 200, :organization => @organization)
      split3         = Factory(:implementer_split, :activity => @activity2,
                               :budget => 200, :spend => 200, :organization => @organization2)
      @activity2.reload
      @activity2.save!

      xls = Reports::ActivityManagerWorkplan.new(@response,@user.organizations).to_xls
      rows = Spreadsheet.open(StringIO.new(xls)).worksheet(0)
      rows.row(0).should == ["Organization Name", "Project Name", "Project Description",
        "Funding Sources", "Activity Name", "Activity Description", "Activity / Other Cost",
        "Activity Budget (USD)", "Implementers", "Targets", "Outputs", "Beneficiaries",
        "Districts worked in/National focus"]
      rows[1,0].should == @organization2.try(:name)
      rows[1,1].should == @project.try(:name)
      rows[1,2].should == @project.try(:description)
      rows[1,3].should == @project.in_flows.map{|ff| ff.organization.name}.join(',')
      rows[1,4].should == ApplicationController.helpers.friendly_name(@activity,50)
      rows[1,5].should == @activity.description
      rows[1,6].should == @activity.class.to_s.titleize
      rows[1,7].should == "100.00"
      rows[1,8].should == @activity.implementer_splits.map{|is| is.organization.name}.join(', ')

      rows[2,0].should == nil
      rows[2,1].should == nil
      rows[2,2].should == nil
      rows[2,3].should == nil
      rows[2,4].should == ApplicationController.helpers.friendly_name(@activity2,50)
      rows[2,5].should == @activity2.description
      rows[2,6].should == @activity2.class.to_s.titleize
      rows[2,7].should == "400.00"
      rows[2,8].should == @activity2.implementer_splits.map{|is| is.organization.name}.join(', ')

      rows[3,0].should == @organization3.try(:name)
    end
  end
end
