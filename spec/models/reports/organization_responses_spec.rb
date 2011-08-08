require File.dirname(__FILE__) + '/../../spec_helper'

describe Reports::OrganizationResponses do
  before :each do
    @header = "Organization Name,Response Status,Project Expenditure,Activity + Other Cost Expenditure," +
      "Expenditure Difference,Project Budget,Activity + Other Cost Budget,Budget Difference"
    Money.default_bank.add_rate(:RWF, :USD, 0.5)
    Money.default_bank.add_rate(:USD, :RWF, 2)
    @organization1  = Factory(:organization, :name => "org1", :currency => "USD")
    @organization2  = Factory(:organization, :name => "org2", :currency => "RWF")
    @request        = Factory(:data_request, :organization => @organization1)
    @response1      = @organization1.latest_response
    @response2      = @organization2.latest_response
    # submit the 2nd one (yeah even if invalid)
    @response2.submitted = true
    @response2.submitted_at = Time.now
    @response2.save(false)
  end

  it "should return the header" do
    Reports::OrganizationResponses.new(@request).csv.split("\n")[0].should == @header
  end

  it "should show all organizations, regardless of status" do
    Reports::OrganizationResponses.new(@request).csv.should == @header + "\n" +
      "org1,Empty / Not Started,0.00,0.00,0.00,0.00,0.00,0.00\norg2,Submitted,0.00,0.00,0.00,0.00,0.00,0.00\n"
  end

  context 'with projects/activities in USD' do
    before :each do
      @project1 = Factory :project, :data_response => @response1
      Factory :activity, :project => @project1, :data_response => @response1,
              :spend => "5", :budget => "10"
    end

    it "should show project totals" do
      Reports::OrganizationResponses.new(@request).csv.split("\n")[1].should ==
        'org1,In Progress,5.00,5.00,0.00,10.00,10.00,0.00'
    end

    it "should show project totals with cents if present" do
      Factory :activity, :project => @project1, :data_response => @response1,
              :spend => "0.20", :budget => "0"
      @project1.save(false)
      Reports::OrganizationResponses.new(@request).csv.split("\n")[1].should ==
        'org1,In Progress,5.20,5.20,0.00,10.00,10.00,0.00'
    end

    context "with activities" do
      before :each do
        @activity1 = Factory :activity, :spend => "12", :budget => "6", :project => @project1,
          :data_response => @response1
      end

      it "should show activity totals" do
        Reports::OrganizationResponses.new(@request).csv.split("\n")[1].should ==
          'org1,In Progress,17.00,17.00,0.00,16.00,16.00,0.00'
      end

      it "should show differences as negative if activity exceeds project" do
        Reports::OrganizationResponses.new(@request).csv.split("\n")[1].should ==
        'org1,In Progress,17.00,17.00,0.00,16.00,16.00,0.00'
      end

      it "should show differences as positive if project exceeds activity" do
        @activity1.spend = 2
        @activity1.save(false)
        Reports::OrganizationResponses.new(@request).csv.split("\n")[1].should ==
          'org1,In Progress,7.00,7.00,0.00,16.00,16.00,0.00'
      end
    end

     context "with other costs" do
        before :each do
          @other_cost1 = Factory :other_cost, :spend => "12", :budget => "6", :data_response => @response1
        end

        it "should show other costs totals" do
          @other_cost1.project = @project1
          @other_cost1.save(false)
          Reports::OrganizationResponses.new(@request).csv.split("\n")[1].should ==
            'org1,In Progress,17.00,17.00,0.00,16.00,16.00,0.00'
        end

        it "should show other costs without a project" do
          Reports::OrganizationResponses.new(@request).csv.split("\n")[1].should ==
           'org1,In Progress,5.00,17.00,-12.00,10.00,16.00,-6.00'
        end
      end
  end

  context 'with projects/activities in USD and RWF' do
    before :each do
      @project1  = Factory :project, :data_response => @response1
      @activity1 = Factory :activity, :spend => "12", :budget => "6",
                           :project => @project1, :data_response => @response1
      @project2  = Factory :project, :data_response => @response2
      @activity2 = Factory :activity, :spend => "18", :budget => "9",
                           :project => @project2, :data_response => @response2
    end

    it "should print totals in USD for simple comparison" do
      report = Reports::OrganizationResponses.new(@request).csv
      report.split("\n")[1].should == 'org1,In Progress,12.00,12.00,0.00,6.00,6.00,0.00'
      report.split("\n")[2].should == 'org2,Submitted,9.00,9.00,0.00,4.50,4.50,0.00'
    end
  end
end

