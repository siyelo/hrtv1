require File.dirname(__FILE__) + '/../spec_helper'

describe Importer do
  before :each do
    basic_setup_sub_activity
    @project.name = 'project1'; @project.save!
    @activity.name = 'activity1'; @activity.save!
    @organization.name = 'selfimplementer1'; @organization.save!
  end

  describe 'API' do
    before :each do
      @implementer2  = Factory(:organization, :name => "implementer2")
      @split2 = Factory(:sub_activity, :data_response => @response,
                              :activity => @activity, :provider => @implementer2)
      @csv_string = <<-EOS
project1,project description,activity1,activity1 description,#{@split.id},selfimplementer1,2,4
,,,,#{@split2.id},selfimplementer2,3,6
new project,blah,new activity,blah activity,,implementer2,4,8
EOS
      @filename = write_csv_with_header(@csv_string)
      @i = Importer.new(@response, @filename)
    end

    it "should return its attributes" do
      @i.response.should == @response
      @i.filename.should == @filename
      @i.import
      @i.projects.size.should == 2
      @i.activities.size.should == 2
    end

    it "should track new splits it creates" do
      @i.new_splits.should == []
    end

    describe 'row parsing' do
      before :each do
        @i.import # seems to have a side effect of hosing @file... ?
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
project1,project description,activity1,activity1 description,#{@split.id},selfimplementer1,99.9,100.1
EOS
    i = Importer.new(@response, write_csv_with_header(csv_string))
    i.projects.should be_empty
    i.import
    i.projects.should_not be_empty
  end

  context "when updating existing records" do
    it "should just update existing implementer when records exist" do
      csv_string = <<-EOS
project1,project description,activity1,activity1 description,#{@split.id},selfimplementer1,99.9,100.1
EOS
      i = Importer.new(@response, write_csv_with_header(csv_string))
      i.import
      i.projects.size.should == 1
      i.activities.size.should == 1
      i.activities[0].implementer_splits.first.implementer_name.should == 'selfimplementer1'
      i.activities[0].implementer_splits.first.spend.to_f.should == 99.9
      i.activities[0].implementer_splits.first.budget.to_f.should == 100.1
    end

    it "should ignore trailing blank lines" do
      csv_string = <<-EOS
project1,project description,activity1,activity1 description,#{@split.id},selfimplementer1,99.9,100.1

EOS
      i = Importer.new(@response, write_csv_with_header(csv_string))
      i.import
      i.projects.size.should == 1
      i.activities.size.should == 1
      i.activities[0].implementer_splits.first.implementer_name.should == 'selfimplementer1'
      i.activities[0].implementer_splits.first.spend.to_f.should == 99.9
      i.activities[0].implementer_splits.first.budget.to_f.should == 100.1
    end

    it "should keep existing, unchanged records" do
      @split.spend = 1
      @split.budget = 2
      @split.save!
      csv_string = <<-EOS
project1,project description,activity1,activity1 description,#{@split.id},#{@split.implementer_name},#{@split.spend},#{@split.budget}
EOS
      i = Importer.new(@response, write_csv_with_header(csv_string))
      i.import
      i.projects.size.should == 1
      i.activities.size.should == 1
      i.activities[0].implementer_splits.first.implementer_name.should == @split.implementer_name
      i.activities[0].implementer_splits.first.spend.to_f.should == @split.spend
      i.activities[0].implementer_splits.first.budget.to_f.should == @split.budget
    end

    it "should discard duplicate implementer rows" do
      csv_string = <<-EOS
project1,project description,activity1,activity1 description,#{@split.id},selfimplementer1,2,4
,,,,#{@split.id},selfimplementer1,3,6
EOS
      i = Importer.new(@response, write_csv_with_header(csv_string))
      i.import
      i.activities[0].implementer_splits.first.implementer_name.should == 'selfimplementer1'
      i.activities[0].implementer_splits.first.spend.to_f.should == 3
      i.activities[0].implementer_splits.first.budget.to_f.should == 6
      i.activities[0].spend.to_f.should == 3
      i.activities[0].budget.to_f.should == 6
    end

    it "should discard several duplicate implementer rows" do
      csv_string = <<-EOS
project1,project description,activity1,activity1 description,#{@split.id},selfimplementer1,2,4
,,,,#{@split.id},selfimplementer1,3,6
,,,,#{@split.id},selfimplementer1,4,8
EOS
      i = Importer.new(@response, write_csv_with_header(csv_string))
      i.import
      i.activities[0].implementer_splits.first.implementer_name.should == 'selfimplementer1'
      i.activities[0].implementer_splits.first.spend.to_f.should == 4
      i.activities[0].implementer_splits.first.budget.to_f.should == 8
      i.activities[0].spend.to_f.should == 4
      i.activities[0].budget.to_f.should == 8
    end

    it "should maintain activity cache" do
      csv_string = <<-EOS
project1,project description,activity1,activity1 description,#{@split.id},selfimplementer1,2,4
EOS
      i = Importer.new(@response, write_csv_with_header(csv_string))
      i.import
      i.activities[0].spend.to_f.should == 2
      i.activities[0].budget.to_f.should == 4
    end

    context "when multiple existing implementers" do
      before :each do
        @implementer2  = Factory(:organization, :name => "implementer2")
        @split2 = Factory(:sub_activity, :data_response => @response,
                                :activity => @activity, :provider => @implementer2)
      end

      it "should update multiple implementers" do
        csv_string = <<-EOS
project1,project description,activity1,activity1 description,#{@split.id},selfimplementer1,2.0,4.0
,,,,#{@split2.id},implementer2,3.0,6.0
EOS
        i = Importer.new(@response, write_csv_with_header(csv_string))
        i.import
        i.activities[0].implementer_splits.first.implementer_name.should == 'selfimplementer1'
        i.activities[0].implementer_splits.first.spend.to_f.should == 2.0
        i.activities[0].implementer_splits.first.budget.to_f.should == 4.0
        i.activities[0].implementer_splits[1].implementer_name.should == 'implementer2'
        i.activities[0].implementer_splits[1].spend.to_f.should == 3.0
        i.activities[0].implementer_splits[1].budget.to_f.should == 6.0
        i.activities[0].spend.to_f.should == 5
        i.activities[0].budget.to_f.should == 10
      end

      it "should update 1 activity plus its multiple implementers" do
        csv_string = <<-EOS
project1,project description,activity1,activity1 NEW description,#{@split.id},selfimplementer1,2.0,4.0
,,,,#{@split2.id},implementer2,3.0,6.0
EOS
        i = Importer.new(@response, write_csv_with_header(csv_string))
        i.import
        i.activities[0].description.should == 'activity1 NEW description'
        i.activities[0].implementer_splits.first.implementer_name.should == 'selfimplementer1'
        i.activities[0].implementer_splits.first.spend.to_f.should == 2.0
        i.activities[0].implementer_splits.first.budget.to_f.should == 4.0
        i.activities[0].implementer_splits[1].implementer_name.should == 'implementer2'
        i.activities[0].implementer_splits[1].spend.to_f.should == 3.0
        i.activities[0].implementer_splits[1].budget.to_f.should == 6.0
        i.activities[0].spend.to_f.should == 5
        i.activities[0].budget.to_f.should == 10
      end

      it "should update existing activity overwriting its multiple implementers" do
        @implementer3  = Factory(:organization, :name => "implementer3")
        csv_string = <<-EOS
project1,project description,activity1,activity1 description,,implementer3,2.0,4.0
EOS
        i = Importer.new(@response, write_csv_with_header(csv_string))
        i.import
        i.activities[0].implementer_splits.size.should == 1
        i.activities[0].implementer_splits.first.implementer_name.should == 'implementer3'
        i.activities[0].implementer_splits.first.spend.to_f.should == 2.0
        i.activities[0].implementer_splits.first.budget.to_f.should == 4.0
        i.activities[0].spend.to_f.should == 2
        i.activities[0].budget.to_f.should == 4
      end

      it "should update the project, plus the activity plus its multiple implementers" do
        csv_string = <<-EOS
project1,project NEW description,activity1,activity1 NEW description,#{@split.id},selfimplementer1,2.0,4.0
,,,,#{@split2.id},implementer2,3.0,6.0
EOS
        i = Importer.new(@response, write_csv_with_header(csv_string))
        i.import
        i.projects.size.should == 1
        i.activities.size.should == 1
        i.projects[0].description.should == 'project NEW description'
        i.activities[0].description.should == 'activity1 NEW description'
        i.activities[0].implementer_splits.first.implementer_name.should == 'selfimplementer1'
        i.activities[0].implementer_splits.first.spend.to_f.should == 2.0
        i.activities[0].implementer_splits.first.budget.to_f.should == 4.0
        i.activities[0].implementer_splits[1].implementer_name.should == 'implementer2'
        i.activities[0].implementer_splits[1].spend.to_f.should == 3.0
        i.activities[0].implementer_splits[1].budget.to_f.should == 6.0
        i.activities[0].spend.to_f.should == 5
        i.activities[0].budget.to_f.should == 10
      end
    end

    it "should update multiple activities and their implementers" do
      @activity2 = Factory(:activity, :data_response => @response, :project => @project)
      @implementer2  = Factory(:organization, :name => "implementer2")
      @split2 = Factory(:sub_activity, :data_response => @response,
                             :activity => @activity2, :provider => @implementer2)
      csv_string = <<-EOS
project1,project description,activity1,activity1 description,#{@split.id},selfimplementer1,2.0,4.0
project1,project description,activity2,activity2 description,#{@split2.id},implementer2,3.0,6.0
EOS
      i = Importer.new(@response, write_csv_with_header(csv_string))
      i.import
      i.activities[0].implementer_splits.first.implementer_name.should == 'selfimplementer1'
      i.activities[0].implementer_splits.first.spend.to_f.should == 2.0
      i.activities[0].implementer_splits.first.budget.to_f.should == 4.0
      i.activities[1].implementer_splits.first.implementer_name.should == 'implementer2'
      i.activities[1].implementer_splits.first.spend.to_f.should == 3.0
      i.activities[1].implementer_splits.first.budget.to_f.should == 6.0
    end

    it "should update multiple implementers" do
      @split2 = Factory(:sub_activity, :data_response => @response,
                             :activity => @activity, :provider => Factory(:organization,
                               :name => "implementer2"))
      @split3 = Factory(:sub_activity, :data_response => @response,
                             :activity => @activity, :provider => Factory(:organization,
                               :name => "implementer3"))
      @split4 = Factory(:sub_activity, :data_response => @response,
                             :activity => @activity, :provider => Factory(:organization,
                               :name => "implementer4"))
      csv_string = <<-EOS
project1,project description,activity1,activity1 description,#{@split.id},selfimplementer1,2.0,4.0
,,,,#{@split2.id},implementer2,3.0,6.0
,,,,#{@split3.id},implementer3,4.0,6.0
,,,,#{@split4.id},implementer4,5.0,6.0
EOS
      i = Importer.new(@response, write_csv_with_header(csv_string))
      i.import
      i.activities[0].implementer_splits[0].implementer_name.should == 'selfimplementer1'
      i.activities[0].implementer_splits[0].spend.to_f.should == 2.0
      i.activities[0].implementer_splits[0].budget.to_f.should == 4.0
      i.activities[0].implementer_splits[1].implementer_name.should == 'implementer2'
      i.activities[0].implementer_splits[1].spend.to_f.should == 3.0
      i.activities[0].implementer_splits[1].budget.to_f.should == 6.0
      i.activities[0].implementer_splits[2].implementer_name.should == 'implementer3'
      i.activities[0].implementer_splits[2].spend.to_f.should == 4.0
      i.activities[0].implementer_splits[2].budget.to_f.should == 6.0
      i.activities[0].implementer_splits[3].implementer_name.should == 'implementer4'
      i.activities[0].implementer_splits[3].spend.to_f.should == 5.0
      i.activities[0].implementer_splits[3].budget.to_f.should == 6.0
    end

    context "when changing multiple activities" do
      before :each do
        @activity2 = Factory(:activity, :data_response => @response, :project => @project)
        @activity3 = Factory(:activity, :data_response => @response, :project => @project)
        @activity4 = Factory(:activity, :data_response => @response, :project => @project)
        @split2 = Factory(:sub_activity, :data_response => @response,
                               :activity => @activity2, :provider => Factory(:organization,
                                 :name => "implementer2"))
        @split3 = Factory(:sub_activity, :data_response => @response,
                               :activity => @activity3, :provider => Factory(:organization,
                                 :name => "implementer3"))
        @split4 = Factory(:sub_activity, :data_response => @response,
                               :activity => @activity4, :provider => Factory(:organization,
                                 :name => "implementer4"))
      end

      it "should update 2 existing activities" do
        csv_string = <<-EOS
  project1,project description,activity1,activity1 description,#{@split.id},selfimplementer1,2.0,4.0
  ,,activity2,d2,#{@split2.id},implementer2,3.0,6.0
  EOS
        i = Importer.new(@response, write_csv_with_header(csv_string))
        i.import
        i.activities[0].implementer_splits[0].implementer_name.should == 'selfimplementer1'
        i.activities[0].implementer_splits[0].spend.to_f.should == 2.0
        i.activities[0].implementer_splits[0].budget.to_f.should == 4.0
        i.activities[1].implementer_splits[0].implementer_name.should == 'implementer2'
        i.activities[1].implementer_splits[0].spend.to_f.should == 3.0
        i.activities[1].implementer_splits[0].budget.to_f.should == 6.0
      end

      it "should update > 2 implementers across multiple activities" do
        csv_string = <<-EOS
  project1,project description,activity1,activity1 description,#{@split.id},selfimplementer1,2.0,4.0
  ,,activity2,d2,#{@split2.id},implementer2,3.0,6.0
  ,,activity3,d3,#{@split3.id},implementer3,4.0,6.0
  ,,activity4,d4,#{@split4.id},implementer4,5.0,6.0
  EOS
        i = Importer.new(@response, write_csv_with_header(csv_string))
        i.import
        i.activities[0].implementer_splits[0].implementer_name.should == 'selfimplementer1'
        i.activities[0].implementer_splits[0].spend.to_f.should == 2.0
        i.activities[0].implementer_splits[0].budget.to_f.should == 4.0
        i.activities[1].implementer_splits[0].implementer_name.should == 'implementer2'
        i.activities[1].implementer_splits[0].spend.to_f.should == 3.0
        i.activities[1].implementer_splits[0].budget.to_f.should == 6.0
        i.activities[2].implementer_splits[0].implementer_name.should == 'implementer3'
        i.activities[2].implementer_splits[0].spend.to_f.should == 4.0
        i.activities[2].implementer_splits[0].budget.to_f.should == 6.0
        i.activities[3].implementer_splits[0].implementer_name.should == 'implementer4'
        i.activities[3].implementer_splits[0].spend.to_f.should == 5.0
        i.activities[3].implementer_splits[0].budget.to_f.should == 6.0
      end

      context "when multiple projects" do
        before :each do
          @project2      = Factory(:project, :data_response => @response)
          @activity21    = Factory(:activity, :data_response => @response, :project => @project2)
          @split21 = Factory(:sub_activity, :data_response => @response,
                       :activity => @activity21, :provider => @organization)
        end

        it "should update existing activities across multiple projects" do
          csv_string = <<-EOS
project2,project2 description,activity21,activity21 description,#{@split21.id},selfimplementer1,2.0,4.0
project1,project1 description,activity1,d1,#{@split.id},selfimplementer1,3.0,6.0
EOS
          i = Importer.new(@response, write_csv_with_header(csv_string))
          i.import
          i.activities[0].implementer_splits[0].implementer_name.should == 'selfimplementer1'
          i.activities[0].implementer_splits[0].spend.to_f.should == 2.0
          i.activities[0].implementer_splits[0].budget.to_f.should == 4.0
          i.activities[1].implementer_splits[0].implementer_name.should == 'selfimplementer1'
          i.activities[1].implementer_splits[0].spend.to_f.should == 3.0
          i.activities[1].implementer_splits[0].budget.to_f.should == 6.0
        end

        it "should update > 2 activities across multiple projects" do
          csv_string = <<-EOS
project2,project2 description,activity21,activity21 description,#{@split21.id},selfimplementer1,1.0,2.0
project1,project1 description,activity1,d1,#{@split.id},selfimplementer1,2.0,3.0
,,activity2,d2,#{@split2.id},implementer2,3.0,6.0
,,activity3,d3,#{@split3.id},implementer3,4.0,6.0
,,activity4,d4,#{@split4.id},implementer4,5.0,6.0
EOS
          i = Importer.new(@response, write_csv_with_header(csv_string))
          i.import
          i.activities[0].implementer_splits[0].implementer_name.should == 'selfimplementer1'
          i.activities[0].implementer_splits[0].spend.to_f.should == 1.0
          i.activities[0].implementer_splits[0].budget.to_f.should == 2.0
          i.activities[1].implementer_splits[0].implementer_name.should == 'selfimplementer1'
          i.activities[1].implementer_splits[0].spend.to_f.should == 2.0
          i.activities[1].implementer_splits[0].budget.to_f.should == 3.0
          i.activities[2].implementer_splits[0].implementer_name.should == 'implementer2'
          i.activities[2].implementer_splits[0].spend.to_f.should == 3.0
          i.activities[2].implementer_splits[0].budget.to_f.should == 6.0
          i.activities[3].implementer_splits[0].implementer_name.should == 'implementer3'
          i.activities[3].implementer_splits[0].spend.to_f.should == 4.0
          i.activities[3].implementer_splits[0].budget.to_f.should == 6.0
          i.activities[4].implementer_splits[0].implementer_name.should == 'implementer4'
          i.activities[4].implementer_splits[0].spend.to_f.should == 5.0
          i.activities[4].implementer_splits[0].budget.to_f.should == 6.0
        end
      end
    end
  end

  it "should assign to a self-implementer if implementer cant be found (new org name)" do
    # we dont want users bulk creating things in the db!
    csv_string = <<-EOS
project1,project description,activity1,activity1 description,,new implementer,2,4
EOS
    i = Importer.new(@response, write_csv_with_header(csv_string))
    i.import
    i.activities[0].implementer_splits.size.should == 1
    i.activities[0].implementer_splits.first.implementer_name.should == 'selfimplementer1'
    i.activities[0].implementer_splits.first.spend.to_f.should == 2
    i.activities[0].implementer_splits.first.budget.to_f.should == 4
  end

  it "should assign to a self-implementer if implementer cant be found (left blank)" do
    @response.organization = Factory(:organization) # create a new org to check that it doesn't
                                                    # just return the first org in the db
    csv_string = <<-EOS
project1,project description,activity1,activity1 description,,,2,4
EOS
    i = Importer.new(@response, write_csv_with_header(csv_string))
    i.import
    i.activities[0].implementer_splits.size.should == 1
    i.activities[0].implementer_splits.first.implementer_name.should == @response.organization.name
    i.activities[0].implementer_splits.first.spend.to_f.should == 2
    i.activities[0].implementer_splits.first.budget.to_f.should == 4
  end

  it "should ignore new implementer name when ID is still given" do
    csv_string = <<-EOS
project1,project description,activity1,activity1 description,#{@split.id},new implementer,2,4
EOS
    i = Importer.new(@response, write_csv_with_header(csv_string))
    i.import
    i.activities[0].implementer_splits.size.should == 1
    i.activities[0].implementer_splits.first.implementer_name.should == 'selfimplementer1'
    i.activities[0].implementer_splits.first.spend.to_f.should == 2
    i.activities[0].implementer_splits.first.budget.to_f.should == 4
    i.activities[0].spend.to_f.should == 2 # check the cache is up to date
    i.activities[0].budget.to_f.should == 4
  end

  it "should discard several duplicate brand new implementer rows" do
    csv_string = <<-EOS
project1,project description,activity1,activity1 description,,new implementer,2,4
,,,,,new implementer,3,6
,,,,,new implementer,4,8
EOS
    i = Importer.new(@response, write_csv_with_header(csv_string))
    i.import
    i.activities[0].implementer_splits.size.should == 1
    i.activities[0].implementer_splits.first.implementer_name.should == 'selfimplementer1'
    i.activities[0].implementer_splits.first.spend.to_f.should == 4
    i.activities[0].implementer_splits.first.budget.to_f.should == 8
  end

  it "should allow an invalid implementer split on a valid activity to be corrected and saved" do
    csv_string = <<-EOS
project1,project description,activity1,activity1 description,,selfimplementer1,aaaa,4
EOS
    i = Importer.new(@response, write_csv_with_header(csv_string))
    i.import
    i.activities[0].implementer_splits.size.should == 1
    i.activities[0].implementer_splits.first.implementer_name.should == 'selfimplementer1'
    i.activities[0].implementer_splits.first.save.should == false
    i.activities[0].implementer_splits.first.spend =  2
    i.activities[0].implementer_splits.first.budget.to_f.should == 4
    i.activities[0].implementer_splits.first.save.should == true
  end

  it "should allow an invalid implementer split on a valid activity with other valid implementers to be corrected and saved" do
    csv_string = <<-EOS
project1,project description,activity1,activity1 description,,selfimplementer1,aaaa,4
,,,,,organization2,3,6
EOS
    @organization2 = Factory(:organization, :name => 'organization2')
    i = Importer.new(@response, write_csv_with_header(csv_string))
    i.import
    i.activities[0].implementer_splits.size.should == 2
    i.activities[0].implementer_splits.first.implementer_name.should == 'selfimplementer1'
    i.activities[0].implementer_splits.first.save.should == false
    i.activities[0].implementer_splits.first.spend =  2
    i.activities[0].implementer_splits.first.budget.to_f.should == 4
    i.activities[0].implementer_splits.first.save.should == true
  end

  it "should allow an invalid activity with valid implementers and a valid project can be corrected and saved" do
    csv_string = <<-EOS
project1,project description,ac,activity1 description,,selfimplementer1,2,4
,,,,,selfimplementer1,3,6
EOS
    i = Importer.new(@response, write_csv_with_header(csv_string))
    i.import
    i.activities[0].implementer_splits.size.should == 2
    i.activities[0].save.should == false
    i.activities[0].name = "Activity Name"
    i.activities[0].save.should == true
    i.activities[0].implementer_splits.size.should == 2
  end

  it "should create an activity even when supplied with incorrect column heading" do
    csv_string = <<-EOS
Project Name,Project Description,HERP DERP,Activity Description,Id,Implementer,Past Expenditure,Current Budget
project1,project description,my activity name,activity1 description,,selfimplementer1,2,4
,,,,,selfimplementer1,3,6
EOS
    i = Importer.new(@response, write_csv(csv_string))
    i.import
    i.projects.size.should == 1
    i.activities[0].implementer_splits.size.should == 2
    i.activities[0].save.should == false
    i.activities[0].errors.on(:name).should == "can't be blank"
    i.activities[0].name.should == ""
  end

  it "should auto trim a long name from project" do
    csv_string = <<-EOS
11111111112222222222333333333344444444445555555555666666666677777777778,project description,act,activity1 description,,selfimplementer1,2,4
EOS
    i = Importer.new(@response, write_csv_with_header(csv_string))
    i.import
    i.projects.size.should == 1
    i.projects[0].activities.size.should == 0 #the association wont be loaded first time round,
    i.activities.size.should == 1 # so you must use the loaded activities not project.activities
    i.projects[0].name.size.should == 64 # auto trim
    i.projects[0].save.should == true
    i.projects[0].activities.size.should == 0 # the new activities weren't saved yet
  end

  it "should allow correcting of invalid project name" do
    csv_string = <<-EOS
,project description,act,activity1 description,,selfimplementer1,2,4
EOS
    i = Importer.new(@response, write_csv_with_header(csv_string))
    i.import
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
project1,project description,activity2,activity2 description,,Shyira HD District Hospital,3,6
EOS
      @implementer2   = Factory(:organization, :name => "Shyira HD District Hospital | Nyabihu")
      @i = Importer.new(@response, write_csv_with_header(csv_string))
      @i.import
    end

    it "recognizes the correct project" do
      @i.activities[0].should be_valid
      @i.activities[0].project.should == @project
    end

    it "should create a budget and spend automatically for the activities" do
      @i.activities[0].implementer_splits.should have(1).item
      @i.activities[0].implementer_splits[0].data_response.should == @response
      @i.activities[0].implementer_splits[0].organization.should == @organization
    end

    it "recognizes the correct implementer: 'Shyira HD District Hospital | Nyabihu'" do
      @i.activities.should have(1).item
      @i.activities[0].save.should == true
      @i.activities[0].implementer_splits.first.implementer.should == @implementer2
    end
  end
end