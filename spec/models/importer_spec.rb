require File.dirname(__FILE__) + '/../spec_helper'

include DelayedJobSpecHelper

describe Importer do
  before :each do
    basic_setup_implementer_split
    @project.name = 'project1'; @project.save!
    @activity.name = 'activity1'; @activity.save!
    @organization.name = 'selfimplementer1'; @organization.save!
  end

  describe 'API' do
    before :each do
      @implementer2  = Factory(:organization, :name => "implementer2")
      @split2    = Factory(:implementer_split, :activity => @activity,
                   :organization => @implementer2)
      @csv_string = <<-EOS
project1,project description,01/01/2010,31/12/2010,activity1,activity1 description,#{@split.id},selfimplementer1,2,4
,,,,,,#{@split2.id},selfimplementer2,3,6
new project,blah,01/01/2010,31/12/2010,new activity,blah activity,,implementer2,4,8
EOS
      @filename = write_csv_with_header(@csv_string)
      @i = Importer.new
    end

    it "should return its attributes" do
      @i.import(@response, @filename)
      @i.response.should == @response
      @i.filename.should == @filename
      @i.projects.size.should == 2
      @i.activities.size.should == 2
    end

    it "should track new splits it creates" do
      @i.import(@response, @filename)
      @i.new_splits.should_not be_empty
    end

    describe 'row parsing' do
      before :each do
        @i.import(@response, @filename) # seems to have a side effect of hosing @file... ?
      end

      it "should carry over a description on subsequent lines" do
        previous_row_name = "some name"
        previous_row_descr = "some descr"
        @i.name_for("", previous_row_name).should == 'some name'
        @i.description_for("", previous_row_descr, "").should == 'some descr'
      end

      it "should find existing splits based on their given id" do
        @i.find_cached_split_using_split_id(@split.id).should == @split
        @i.find_cached_activity_using_split_id(@split.id).should == @activity
      end

      it "should always return the same activity object from the cache" do
        activity = @i.activities.first
        @i.find_cached_activity_using_split_id(@split.id).should === activity
      end

    end
  end

  describe 'importing excel files' do
    before :each do
      @implementer2  = Factory(:organization, :name => "implementer2")
      @split2    = Factory(:implementer_split, :activity => @activity,
                   :organization => @implementer2)
      rows = []
      rows << ['project1','project description','01/01/2010','31/12/2010','activity1','activity1 description',"#{@split.id}",'selfimplementer1','2','4']
      rows << ['','','','','','',"#{@split2.id}",'selfimplementer2','3','6']
      rows << ['new project','blah','01/01/2010','31/12/2010','new activity','blah activity','','implementer2','4','8']
      @filename = write_xls_with_header(rows)
      @i = Importer.new
    end

    it "should return its attributes" do
      @i.import(@response, @filename)
      @i.response.should == @response
      @i.filename.should == @filename
      @i.projects.size.should == 2
      @i.activities.size.should == 2
    end

    it "should track new splits it creates" do
      @i.import(@response, @filename)
      @i.new_splits.should_not be_empty
    end

    describe 'row parsing' do
      before :each do
        @i.import(@response, @filename) # seems to have a side effect of hosing @file... ?
      end

      it "should carry over a description on subsequent lines" do
        previous_row_name = "some name"
        previous_row_descr = "some descr"
        @i.name_for("", previous_row_name).should == 'some name'
        @i.description_for("", previous_row_descr, "").should == 'some descr'
      end

      it "should find existing splits based on their given id" do
        @i.find_cached_split_using_split_id(@split.id).should == @split
        @i.find_cached_activity_using_split_id(@split.id).should == @activity
      end

      it "should always return the same activity object from the cache" do
        activity = @i.activities.first
        @i.find_cached_activity_using_split_id(@split.id).should === activity
      end

    end
  end

  it "should import a file" do
    csv_string = <<-EOS
project1,project description,01/01/2010,31/12/2010,activity1,activity1 description,#{@split.id},selfimplementer1,99.9,100.1
EOS
    i = Importer.new
    i.import(@response, write_csv_with_header(csv_string))
    i.projects.should_not be_empty
  end

  it "should show project errors on import" do
    csv_string = <<-EOS
,project description,01/01/2010,31/12/2010,,activity1 description,#{@split.id},selfimplementer1,99.9,aaa
EOS
    i = Importer.new
    i.import(@response, write_csv_with_header(csv_string))
    i.projects.first.errors.on(:name).should == ["can't be blank", "is too short (minimum is 1 characters)"]
  end

  it "should have default self-funder on import of new project" do
    csv_string = <<-EOS
newproj,project description,01/01/2010,31/12/2010,act name,activity1 description,#{@split.id},selfimplementer1,99.9,100.1
EOS
    i = Importer.new
    i.import(@response, write_csv_with_header(csv_string))
    i.projects.size.should == 1
    i.projects.first.should be_valid
    i.projects.first.name.should == 'newproj'
    i.projects.first.in_flows.size.should == 1
  end

  it "should show activity errors on import" do
    csv_string = <<-EOS
project,project description,01/01/2010,31/12/2010,,activity1 description,#{@split.id},selfimplementer1,99.9,100
EOS
    i = Importer.new
    i.import(@response, write_csv_with_header(csv_string))
    i.activities.first.errors.on(:name)[0].should == "can't be blank"
  end

  it "should show implementer split errors on import" do
    csv_string = <<-EOS
project,project description,01/01/2010,31/12/2010,activity,activity1 description,#{@split.id},selfimplementer1,,aaa
EOS
    i = Importer.new
    i.import(@response, write_csv_with_header(csv_string))
    i.activities.first.implementer_splits.first.errors.on(:budget).should == "is not a number"
  end

  it "should find implementer name in substring" do
    csv_string = <<-EOS
project,project description,01/01/2010,31/12/2010,activity,activity1 description,,lfimplemente,99.9,0
EOS
    i = Importer.new
    i.import(@response, write_csv_with_header(csv_string))
    i.activities.first.implementer_splits.first.organization.should == @split.organization
  end

  it "should find implementer name by first word" do
    csv_string = <<-EOS
project,project description,01/01/2010,31/12/2010,activity,activity1 description,,selfimplementer1 blarpants,99.9,0
EOS
    i = Importer.new
    i.import(@response, write_csv_with_header(csv_string))
    i.activities.first.implementer_splits.first.organization.should == @split.organization
  end

  it "should try parse different date formats" do
    csv_string = <<-EOS
project,project description,2010-01-15,2010/12/31,activity,activity1 description,#{@split.id},selfimplementer1,99.9,100
project2,project description,15-01-2010,31/12/2010,activity,activity1 description,,selfimplementer1,99.9,100
EOS
    i = Importer.new
    i.import(@response, write_csv_with_header(csv_string))
    i.projects.first.start_date.to_s.should == "2010-01-15"
    i.projects.first.end_date.to_s.should   == "2010-12-31"
    i.projects[1].start_date.to_s.should == "2010-01-15"
    i.projects[1].end_date.to_s.should   == "2010-12-31"
  end

  it "should return a blank string if a date cannot be parsed" do
    csv_string = <<-EOS
project,project description,99/99/99,2010/12/31,activity,activity1 description,#{@split.id},selfimplementer1,99.9,100
EOS
    i = Importer.new
    i.import(@response, write_csv_with_header(csv_string))
    i.projects.first.start_date.to_s.should == ""
    i.projects.first.errors.on(:start_date).should == "is not a valid date"
  end

  it "should allow blanks for start date and end date respectively if date columns are not found" do
    csv_string = <<-EOS
Project Name,Project Description,Activity Name,Activity Description,Id,Implementer,Past Expenditure,Current Budget
new project,project description,activity,activity1 description,,selfimplementer1,99.9,100
EOS
    i = Importer.new
    i.import(@response, write_csv(csv_string))
    i.projects.first.start_date.should == nil
    i.projects.first.end_date.should == nil
  end

  it "should NOT overwrite an existing project start/end date if the start/end date in the CSV is blank" do
    csv_string = <<-EOS
project,project description,2010/01/01,2010/12/31,activity,activity1 description,#{@split.id},selfimplementer1,99.9,100
,,,,activity,activity1 description,#{@split.id},selfimplementer1,99.9,100
EOS
    i = Importer.new
    i.import(@response, write_csv_with_header(csv_string))
    i.projects.first.start_date.to_s.should == "2010-01-01"
  end

  it "should handle utf8 encoding" do
    csv_string = <<-EOS
project1,project description with utf chars äóäó,activity1,01/01/2010,31/12/2010,activity1 description,#{@split.id},selfimplementer1,99.9,100.1
EOS
    i = Importer.new
    i.import(@response, write_csv_with_header(csv_string))
    i.projects.first.description.should == "project description with utf chars äóäó"
  end

  it "should handle utf16 encoding" do
    csv_string = <<-EOS
project1,project description with Norwegian: æøå. French: êèé,01/01/2010,31/12/2010,activity1,activity1 description,#{@split.id},selfimplementer1,99.9,100.1
EOS
    i = Importer.new
    i.import(@response, write_csv_with_header(csv_string))
    i.projects.first.description.should == "project description with Norwegian: æøå. French: êèé"
  end

  context "when updating existing records" do
    it "should just update existing implementer when records exist" do
      csv_string = <<-EOS
project1,project description,01/01/2010,31/12/2010,activity1,activity1 description,#{@split.id},selfimplementer1,99.9,100.1
EOS
      i = Importer.new
      i.import(@response, write_csv_with_header(csv_string))
      i.projects.size.should == 1
      i.activities.size.should == 1
      i.activities[0].implementer_splits.first.organization_name.should == 'selfimplementer1'
      i.activities[0].implementer_splits.first.spend.to_f.should == 99.9
      i.activities[0].implementer_splits.first.budget.to_f.should == 100.1
      i.activities[0].implementer_splits.first.marked_for_destruction?.should == nil
    end

    it "should ignore trailing blank lines" do
      csv_string = <<-EOS
project1,project description,01/01/2010,31/12/2010,activity1,activity1 description,#{@split.id},selfimplementer1,99.9,100.1

EOS
      i = Importer.new
      i.import(@response, write_csv_with_header(csv_string))
      i.projects.size.should == 1
      i.activities.size.should == 1
      i.activities[0].implementer_splits.first.organization_name.should == 'selfimplementer1'
      i.activities[0].implementer_splits.first.spend.to_f.should == 99.9
      i.activities[0].implementer_splits.first.budget.to_f.should == 100.1
    end

    it "should truncate and strip long names" do
      csv_string = <<-EOS
"Coordination, planning, M&E and partnership of the national HIV 1234567",project description,01/01/2010,31/12/2010,activity1,activity1 description,#{@split.id},selfimplementer1,99.9,100.1

EOS
      i = Importer.new
      i.import(@response, write_csv_with_header(csv_string))
      i.projects.size.should == 1
      i.projects[0].name.should == 'Coordination, planning, M&E and partnership of the national HIV'
    end

    it "should keep existing, unchanged splits" do
      @split.spend = 1
      @split.budget = 2
      @split.save!
      csv_string = <<-EOS
project1,project description,01/01/2010,31/12/2010,activity1,activity1 description,#{@split.id},#{@split.organization_name},#{@split.spend},#{@split.budget}
EOS
      i = Importer.new
      i.import(@response, write_csv_with_header(csv_string))
      i.projects.size.should == 1
      i.activities.size.should == 1
      i.activities[0].implementer_splits.first.organization_name.should == @split.organization_name
      i.activities[0].implementer_splits.first.spend.to_f.should == @split.spend
      i.activities[0].implementer_splits.first.budget.to_f.should == @split.budget
      i.activities[0].implementer_splits.first.changed?.should == true
      i.activities[0].implementer_splits.first.marked_for_destruction?.should == nil

    end

    it "should discard duplicate implementer rows" do
      csv_string = <<-EOS
project1,project description,01/01/2010,31/12/2010,activity1,activity1 description,#{@split.id},selfimplementer1,2,4
,,,,,,#{@split.id},selfimplementer1,3,6
EOS
      i = Importer.new
      i.import(@response, write_csv_with_header(csv_string))
      i.activities[0].implementer_splits.first.organization_name.should == 'selfimplementer1'
      i.activities[0].implementer_splits.first.spend.to_f.should == 3
      i.activities[0].implementer_splits.first.budget.to_f.should == 6
      i.activities[0].spend.to_f.should == 3
      i.activities[0].budget.to_f.should == 6
    end

    it "should discard several duplicate implementer rows" do
      csv_string = <<-EOS
project1,project description,01/01/2010,31/12/2010,activity1,activity1 description,#{@split.id},selfimplementer1,2,4
,,,,,,#{@split.id},selfimplementer1,3,6
,,,,,,#{@split.id},selfimplementer1,4,8
EOS
      i = Importer.new
      i.import(@response, write_csv_with_header(csv_string))
      i.activities[0].implementer_splits.first.organization_name.should == 'selfimplementer1'
      i.activities[0].implementer_splits.first.spend.to_f.should == 4
      i.activities[0].implementer_splits.first.budget.to_f.should == 8
      i.activities[0].spend.to_f.should == 4
      i.activities[0].budget.to_f.should == 8
    end

    it "should maintain activity cache" do
      csv_string = <<-EOS
project1,project description,01/01/2010,31/12/2010,activity1,activity1 description,#{@split.id},selfimplementer1,2,4
EOS
      i = Importer.new
      i.import(@response, write_csv_with_header(csv_string))
      i.activities[0].spend.to_f.should == 2
      i.activities[0].budget.to_f.should == 4
    end

    context "when multiple existing implementers" do
      before :each do
        @implementer2  = Factory(:organization, :name => "implementer2")
        @split2 = Factory :implementer_split, :activity => @activity,
          :organization => @implementer2
      end

      it "should find a previously imported project with a stripped & truncated name" do
        csv_string = <<-EOS
"Coordination, planning, M&E and partnership of the national HIV 1234567",project description,01/01/2010,31/12/2010,activity1,activity1 description,#{@split.id},selfimplementer1,99.9,100.1
,,,,,,,implementer2,99.9,100.1
EOS
        i = Importer.new
        i.import(@response, write_csv_with_header(csv_string))
        i.projects.size.should == 1
        i.projects[0].name == 'Coordination, planning, M&E and partnership of the national HIV'
      end

      it "should update multiple implementers" do
        csv_string = <<-EOS
project1,project description,01/01/2010,31/12/2010,activity1,activity1 description,#{@split.id},selfimplementer1,2.0,4.0
,,,,,,#{@split2.id},implementer2,3.0,6.0
EOS
        i = Importer.new
        i.import(@response, write_csv_with_header(csv_string))
        i.activities[0].implementer_splits.first.organization_name.should == 'selfimplementer1'
        i.activities[0].implementer_splits.first.spend.to_f.should == 2.0
        i.activities[0].implementer_splits.first.budget.to_f.should == 4.0
        i.activities[0].implementer_splits[1].organization_name.should == 'implementer2'
        i.activities[0].implementer_splits[1].spend.to_f.should == 3.0
        i.activities[0].implementer_splits[1].budget.to_f.should == 6.0
        i.activities[0].spend.to_f.should == 5
        i.activities[0].budget.to_f.should == 10
      end

      it "should not create dummy self implementer on existing activities" do
        csv_string = <<-EOS
project1,project description,01/01/2010,31/12/2010,activity1,activity1 description,#{@split2.id},implementer2,2.0,4.0
EOS
        i = Importer.new
        i.import(@response, write_csv_with_header(csv_string))
        i.activities[0].implementer_splits.size.should == 2
        i.activities[0].implementer_splits.first.marked_for_destruction?.should == true
        i.activities[0].implementer_splits[1].organization_name.should == 'implementer2'
      end

      it "should not create dummy self implementer on brand new activities" do
        csv_string = <<-EOS
project1,project description,01/01/2010,31/12/2010,activity BLAR,activity blar description,#{@split2.id},implementer2,2.0,4.0
EOS
        i = Importer.new
        i.import(@response, write_csv_with_header(csv_string))
        i.activities[0].implementer_splits.size.should == 2
        i.activities[0].implementer_splits.first.marked_for_destruction?.should == true
        i.activities[0].implementer_splits[1].organization_name.should == 'implementer2'
      end

      it "should update 1 activity plus its multiple implementers" do
        csv_string = <<-EOS
project1,project description,01/01/2010,31/12/2010,activity1,activity1 NEW description,#{@split.id},selfimplementer1,2.0,4.0
,,,,,,#{@split2.id},implementer2,3.0,6.0
EOS
        i = Importer.new
        i.import(@response, write_csv_with_header(csv_string))
        i.activities[0].description.should == 'activity1 NEW description'
        i.activities[0].implementer_splits.first.organization_name.should == 'selfimplementer1'
        i.activities[0].implementer_splits.first.spend.to_f.should == 2.0
        i.activities[0].implementer_splits.first.budget.to_f.should == 4.0
        i.activities[0].implementer_splits[1].organization_name.should == 'implementer2'
        i.activities[0].implementer_splits[1].spend.to_f.should == 3.0
        i.activities[0].implementer_splits[1].budget.to_f.should == 6.0
        i.activities[0].spend.to_f.should == 5
        i.activities[0].budget.to_f.should == 10
      end

      it "should update existing activity overwriting its multiple implementers" do
        @implementer3  = Factory(:organization, :name => "implementer3")
        csv_string = <<-EOS
project1,project description,01/01/2010,31/12/2010,activity1,activity1 description,,implementer3,2.0,4.0
EOS
        i = Importer.new
        i.import(@response, write_csv_with_header(csv_string))
        i.activities[0].implementer_splits.size.should == 3
        i.activities[0].implementer_splits[0].marked_for_destruction?.should == true
        i.activities[0].implementer_splits[1].marked_for_destruction?.should == true
        i.activities[0].implementer_splits[2].organization_name.should == 'implementer3'
        i.activities[0].implementer_splits[2].spend.to_f.should == 2.0
        i.activities[0].implementer_splits[2].budget.to_f.should == 4.0
        i.activities[0].implementer_splits[2].marked_for_destruction?.should == nil
      end

      it "should update the project, plus the activity plus its multiple implementers" do
        csv_string = <<-EOS
project1,project NEW description,01/01/2010,31/12/2010,activity1,activity1 NEW description,#{@split.id},selfimplementer1,2.0,4.0
,,,,,,#{@split2.id},implementer2,3.0,6.0
EOS
        i = Importer.new
        i.import(@response, write_csv_with_header(csv_string))
        i.projects.size.should == 1
        i.activities.size.should == 1
        i.projects[0].description.should == 'project NEW description'
        i.activities[0].description.should == 'activity1 NEW description'
        i.activities[0].implementer_splits.first.organization_name.should == 'selfimplementer1'
        i.activities[0].implementer_splits.first.spend.to_f.should == 2.0
        i.activities[0].implementer_splits.first.budget.to_f.should == 4.0
        i.activities[0].implementer_splits[1].organization_name.should == 'implementer2'
        i.activities[0].implementer_splits[1].spend.to_f.should == 3.0
        i.activities[0].implementer_splits[1].budget.to_f.should == 6.0
        i.activities[0].spend.to_f.should == 5
        i.activities[0].budget.to_f.should == 10
      end
    end

    it "should update multiple activities and their implementers" do
      @activity2 = Factory(:activity, :data_response => @response, :project => @project)
      @implementer2  = Factory(:organization, :name => "implementer2")
      @split2 = Factory :implementer_split, :activity => @activity2,
        :organization => @implementer2
      csv_string = <<-EOS
project1,project description,01/01/2010,31/12/2010,activity1,activity1 description,#{@split.id},selfimplementer1,2.0,4.0
project1,project description,01/01/2010,31/12/2010,activity2,activity2 description,#{@split2.id},implementer2,3.0,6.0
EOS
      i = Importer.new
      i.import(@response, write_csv_with_header(csv_string))
      i.activities[0].implementer_splits.first.organization_name.should == 'selfimplementer1'
      i.activities[0].implementer_splits.first.spend.to_f.should == 2.0
      i.activities[0].implementer_splits.first.budget.to_f.should == 4.0
      i.activities[1].implementer_splits.first.organization_name.should == 'implementer2'
      i.activities[1].implementer_splits.first.spend.to_f.should == 3.0
      i.activities[1].implementer_splits.first.budget.to_f.should == 6.0
    end

    it "should update multiple implementers" do
      @split2 = Factory :implementer_split, :activity => @activity,
        :organization => Factory(:organization, :name => "implementer2")
      @split3 = Factory :implementer_split, :activity => @activity,
        :organization => Factory(:organization, :name => "implementer3")
      @split4 = Factory :implementer_split, :activity => @activity,
        :organization => Factory(:organization, :name => "implementer4")
      csv_string = <<-EOS
project1,project description,01/01/2010,31/12/2010,activity1,activity1 description,#{@split.id},selfimplementer1,2.0,4.0
,,,,,,#{@split2.id},implementer2,3.0,6.0
,,,,,,#{@split3.id},implementer3,4.0,6.0
,,,,,,#{@split4.id},implementer4,5.0,6.0
EOS
      i = Importer.new
      i.import(@response, write_csv_with_header(csv_string))
      i.activities[0].implementer_splits[0].organization_name.should == 'selfimplementer1'
      i.activities[0].implementer_splits[0].spend.to_f.should == 2.0
      i.activities[0].implementer_splits[0].budget.to_f.should == 4.0
      i.activities[0].implementer_splits[1].organization_name.should == 'implementer2'
      i.activities[0].implementer_splits[1].spend.to_f.should == 3.0
      i.activities[0].implementer_splits[1].budget.to_f.should == 6.0
      i.activities[0].implementer_splits[2].organization_name.should == 'implementer3'
      i.activities[0].implementer_splits[2].spend.to_f.should == 4.0
      i.activities[0].implementer_splits[2].budget.to_f.should == 6.0
      i.activities[0].implementer_splits[3].organization_name.should == 'implementer4'
      i.activities[0].implementer_splits[3].spend.to_f.should == 5.0
      i.activities[0].implementer_splits[3].budget.to_f.should == 6.0
    end

    context "when changing multiple activities" do
      before :each do
        @activity2 = Factory(:activity, :data_response => @response, :project => @project)
        @activity3 = Factory(:activity, :data_response => @response, :project => @project)
        @activity4 = Factory(:activity, :data_response => @response, :project => @project)
        @split2    = Factory(:implementer_split, :activity => @activity2,
                      :organization => Factory(:organization, :name => "implementer2"))
        @split3    = Factory(:implementer_split, :activity => @activity3,
                      :organization => Factory(:organization, :name => "implementer3"))
        @split4 = Factory(:implementer_split, :activity => @activity4,
                      :organization => Factory(:organization, :name => "implementer4"))
      end

      it "should update 2 existing activities" do
        csv_string = <<-EOS
project1,project description,01/01/2010,31/12/2010,activity1,activity1 description,#{@split.id},selfimplementer1,2.0,4.0
,,,,activity2,d2,#{@split2.id},implementer2,3.0,6.0
EOS
        i = Importer.new
        i.import(@response, write_csv_with_header(csv_string))
        i.activities[0].implementer_splits[0].organization_name.should == 'selfimplementer1'
        i.activities[0].implementer_splits[0].spend.to_f.should == 2.0
        i.activities[0].implementer_splits[0].budget.to_f.should == 4.0
        i.activities[1].implementer_splits[0].organization_name.should == 'implementer2'
        i.activities[1].implementer_splits[0].spend.to_f.should == 3.0
        i.activities[1].implementer_splits[0].budget.to_f.should == 6.0
      end

      it "should update > 2 implementers across multiple activities" do
        csv_string = <<-EOS
project1,project description,01/01/2010,31/12/2010,activity1,activity1 description,#{@split.id},selfimplementer1,2.0,4.0
,,,,activity2,d2,#{@split2.id},implementer2,3.0,6.0
,,,,activity3,d3,#{@split3.id},implementer3,4.0,6.0
,,,,activity4,d4,#{@split4.id},implementer4,5.0,6.0
EOS
        i = Importer.new
        i.import(@response, write_csv_with_header(csv_string))
        i.activities[0].implementer_splits[0].organization_name.should == 'selfimplementer1'
        i.activities[0].implementer_splits[0].spend.to_f.should == 2.0
        i.activities[0].implementer_splits[0].budget.to_f.should == 4.0
        i.activities[1].implementer_splits[0].organization_name.should == 'implementer2'
        i.activities[1].implementer_splits[0].spend.to_f.should == 3.0
        i.activities[1].implementer_splits[0].budget.to_f.should == 6.0
        i.activities[2].implementer_splits[0].organization_name.should == 'implementer3'
        i.activities[2].implementer_splits[0].spend.to_f.should == 4.0
        i.activities[2].implementer_splits[0].budget.to_f.should == 6.0
        i.activities[3].implementer_splits[0].organization_name.should == 'implementer4'
        i.activities[3].implementer_splits[0].spend.to_f.should == 5.0
        i.activities[3].implementer_splits[0].budget.to_f.should == 6.0
      end

      context "when multiple projects" do
        before :each do
          @project2      = Factory(:project, :data_response => @response)
          @activity21    = Factory(:activity, :data_response => @response, :project => @project2)
          @split21    = Factory(:implementer_split, :activity => @activity21,
                       :organization => @organization)
        end

        it "should update existing activities across multiple projects" do
          csv_string = <<-EOS
project2,project2 description,01/01/2010,31/12/2010,activity21,activity21 description,#{@split21.id},selfimplementer1,2.0,4.0
project1,project1 description,01/01/2010,31/12/2010,activity1,d1,#{@split.id},selfimplementer1,3.0,6.0
EOS
          i = Importer.new
          i.import(@response, write_csv_with_header(csv_string))
          i.activities[0].implementer_splits[0].organization_name.should == 'selfimplementer1'
          i.activities[0].implementer_splits[0].spend.to_f.should == 2.0
          i.activities[0].implementer_splits[0].budget.to_f.should == 4.0
          i.activities[1].implementer_splits[0].organization_name.should == 'selfimplementer1'
          i.activities[1].implementer_splits[0].spend.to_f.should == 3.0
          i.activities[1].implementer_splits[0].budget.to_f.should == 6.0
        end

        it "should update > 2 activities across multiple projects" do
          csv_string = <<-EOS
project2,project2 description,01/01/2010,31/12/2010,activity21,activity21 description,#{@split21.id},selfimplementer1,1.0,2.0
project1,project1 description,01/01/2010,31/12/2010,activity1,d1,#{@split.id},selfimplementer1,2.0,3.0
,,,,activity2,d2,#{@split2.id},implementer2,3.0,6.0
,,,,activity3,d3,#{@split3.id},implementer3,4.0,6.0
,,,,activity4,d4,#{@split4.id},implementer4,5.0,6.0
EOS
          i = Importer.new
          i.import(@response, write_csv_with_header(csv_string))
          i.activities[0].implementer_splits[0].organization_name.should == 'selfimplementer1'
          i.activities[0].implementer_splits[0].spend.to_f.should == 1.0
          i.activities[0].implementer_splits[0].budget.to_f.should == 2.0
          i.activities[1].implementer_splits[0].organization_name.should == 'selfimplementer1'
          i.activities[1].implementer_splits[0].spend.to_f.should == 2.0
          i.activities[1].implementer_splits[0].budget.to_f.should == 3.0
          i.activities[2].implementer_splits[0].organization_name.should == 'implementer2'
          i.activities[2].implementer_splits[0].spend.to_f.should == 3.0
          i.activities[2].implementer_splits[0].budget.to_f.should == 6.0
          i.activities[3].implementer_splits[0].organization_name.should == 'implementer3'
          i.activities[3].implementer_splits[0].spend.to_f.should == 4.0
          i.activities[3].implementer_splits[0].budget.to_f.should == 6.0
          i.activities[4].implementer_splits[0].organization_name.should == 'implementer4'
          i.activities[4].implementer_splits[0].spend.to_f.should == 5.0
          i.activities[4].implementer_splits[0].budget.to_f.should == 6.0
        end
      end
    end
  end

  it "should assign to nil if implementer cant be found (new org name)" do
    # we dont want users bulk creating things in the db!
    csv_string = <<-EOS
project1,project description,01/01/2010,31/12/2010,activity1,activity1 description,,new implementer,2,4
EOS
    i = Importer.new
    i.import(@response, write_csv_with_header(csv_string))
    i.activities[0].implementer_splits.size.should == 2 # new one plus existing split
    i.activities[0].implementer_splits[1].organization.should == nil
    i.activities[0].implementer_splits[1].spend.to_f.should == 2
    i.activities[0].implementer_splits[1].budget.to_f.should == 4
  end

  it "should assign to nil if implementer cant be found (left blank)" do
    @response.organization = Factory(:organization) # create a new org to check that it doesn't
                                                    # just return the first org in the db
    csv_string = <<-EOS
project1,project description,01/01/2010,31/12/2010,activity1,activity1 description,,,2,4
EOS
    i = Importer.new
    i.import(@response, write_csv_with_header(csv_string))
    i.activities[0].implementer_splits.size.should == 2
    i.activities[0].implementer_splits[1].organization.should == nil
    i.activities[0].implementer_splits[1].spend.to_f.should == 2
    i.activities[0].implementer_splits[1].budget.to_f.should == 4
  end

  it "should ignore new implementer name when ID is still given" do
    csv_string = <<-EOS
project1,project description,01/01/2010,31/12/2010,activity1,activity1 description,#{@split.id},new implementer,2,4
EOS
    i = Importer.new
    i.import(@response, write_csv_with_header(csv_string))
    i.activities[0].implementer_splits.size.should == 1
    i.activities[0].implementer_splits.first.organization.should == nil
    i.activities[0].implementer_splits.first.spend.to_f.should == 2
    i.activities[0].implementer_splits.first.budget.to_f.should == 4
    i.activities[0].spend.to_f.should == 2 # check the cache is up to date
    i.activities[0].budget.to_f.should == 4
  end

  it "should discard several duplicate brand new implementer rows" do
    csv_string = <<-EOS
project1,project description,01/01/2010,31/12/2010,activity1,activity1 description,,new implementer,2,4
,,,,,,,new implementer,3,6
,,,,,,,new implementer,4,8
EOS
    i = Importer.new
    i.import(@response, write_csv_with_header(csv_string))
    i.activities[0].implementer_splits.size.should == 4
    i.activities[0].implementer_splits.first.marked_for_destruction?.should == true
    i.activities[0].implementer_splits[1].organization.should == nil
    i.activities[0].implementer_splits[1].spend.to_f.should == 2
    i.activities[0].implementer_splits[1].budget.to_f.should == 4
    i.activities[0].implementer_splits[2].organization.should == nil
    i.activities[0].implementer_splits[2].spend.to_f.should == 3
    i.activities[0].implementer_splits[2].budget.to_f.should == 6
    i.activities[0].implementer_splits[3].organization.should == nil
    i.activities[0].implementer_splits[3].spend.to_f.should == 4
    i.activities[0].implementer_splits[3].budget.to_f.should == 8
  end

  it "should allow an invalid implementer split on a valid activity to be corrected and saved" do
    csv_string = <<-EOS
project1,project description,01/01/2010,31/12/2010,activity1,activity1 description,,selfimplementer1,aaaa,
EOS
    i = Importer.new
    i.import(@response, write_csv_with_header(csv_string))
    i.activities[0].implementer_splits.size.should == 1
    i.activities[0].implementer_splits.first.organization_name.should == 'selfimplementer1'
    i.activities[0].implementer_splits.first.save.should == false
    i.activities[0].implementer_splits.first.spend =  2
    i.activities[0].implementer_splits.first.save.should == true
  end

  it "should allow an invalid implementer split on a valid activity with other valid implementers to be corrected and saved" do
    csv_string = <<-EOS
project1,project description,01/01/2010,31/12/2010,activity1,activity1 description,,selfimplementer1,aaaa,
,,,,,,,organization2,3,6
EOS
    @organization2 = Factory(:organization, :name => 'organization2')
    i = Importer.new
    i.import(@response, write_csv_with_header(csv_string))
    i.activities[0].implementer_splits.size.should == 2
    i.activities[0].implementer_splits.first.organization_name.should == 'selfimplementer1'
    i.activities[0].implementer_splits.first.save.should == false
    i.activities[0].implementer_splits.first.spend =  2
    i.activities[0].implementer_splits.first.save.should == true
  end

  it "should allow an invalid activity with valid implementers and a valid project can be corrected and saved" do
    organization2 = Factory(:organization, :name => 'selfimplementer2')
    csv_string = <<-EOS
project1,project description,01/01/2010,31/12/2010,ac,activity1 description,,selfimplementer1,2,4
,,,,,,,selfimplementer2,3,6
EOS
    i = Importer.new
    i.import(@response, write_csv_with_header(csv_string))
    i.activities[0].implementer_splits.size.should == 2
    i.activities[0].save.should == false
    i.activities[0].name = "Activity Name"
    i.activities[0].valid?
    i.activities[0].save.should == true
    i.activities[0].implementer_splits.size.should == 2
  end

  it "should create an activity even when supplied with incorrect column heading" do
    csv_string = <<-EOS
Project Name,project description,01/01/2010,31/12/2010,HERP DERP,Activity Description,Id,Implementer,Past Expenditure,Current Budget
project1,project description,01/01/2010,31/12/2010,my activity name,activity1 description,,selfimplementer1,2,4
,,,,,,,selfimplementer1,3,6
EOS
    i = Importer.new
    i.import(@response, write_csv(csv_string))
    i.projects.size.should == 1
    i.activities[0].implementer_splits.size.should == 2
    i.activities[0].save.should == false
    i.activities[0].errors.on(:name)[0].should == "can't be blank"
    i.activities[0].name.should == ""
  end

  it "should auto trim a long name from project" do
    csv_string = <<-EOS
11111111112222222222333333333344444444445555555555666666666677777777778,project description,01/01/2010,31/12/2010,act,activity1 description,,selfimplementer1,2,4
EOS
    i = Importer.new
    i.import(@response, write_csv_with_header(csv_string))
    i.projects.size.should == 1
    i.projects[0].activities.size.should == 0 #the association wont be loaded first time round,
    i.activities.size.should == 1 # so you must use the loaded activities not project.activities
    i.projects[0].name.size.should == 64 # auto trim
    i.projects[0].save.should == true
    i.projects[0].activities.size.should == 0 # the new activities weren't saved yet
  end

  it "should allow correcting of invalid project name" do
    csv_string = <<-EOS
,project description,01/01/2010,31/12/2010,act,activity1 description,,selfimplementer1,2,4
EOS
    i = Importer.new
    i.import(@response, write_csv_with_header(csv_string))
    i.projects.size.should == 1
    i.projects[0].activities.size.should == 0 #the association wont be loaded first time round,
    i.activities.size.should == 1 # so you must use the loaded activities not project.activities
    i.projects[0].save.should == false
    i.projects[0].errors.on(:name).should == ["can't be blank", "is too short (minimum is 1 characters)"]
    i.projects[0].name = "New name"
    i.projects[0].save.should == true
  end

  context "when adding new activity and existing implementer" do
    before :each do
      csv_string = <<-EOS
project1,project description,01/01/2010,31/12/2010,activity2,activity2 description,,Shyira HD District Hospital,3,6
EOS
      @implementer2   = Factory(:organization, :name => "Shyira HD District Hospital | Nyabihu")
      @i = Importer.new
      @i.import(@response, write_csv_with_header(csv_string))
    end

    it "recognizes the correct project" do
      @i.activities[0].should be_valid
      @i.activities[0].project.should == @project
    end

    it "recognizes the correct implementer: 'Shyira HD District Hospital | Nyabihu'" do
      @i.activities.should have(1).item
      @i.activities[0].save.should == true
      @i.activities[0].implementer_splits.first.organization.should == @implementer2
    end
  end

  it "should import and save a file" do
    csv_string = <<-EOS
project2,project description,01/01/2010,31/12/2010,activity1,activity1 description,,selfimplementer1,99.9,100.1
EOS
    @response.projects.count.should == 1
    i = Importer.new
    i.import_and_save(@response, File.open(write_csv_with_header(csv_string)).read)
    run_delayed_jobs
    @response.projects.count.should == 2
  end
end
