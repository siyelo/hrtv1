shared_examples_for "project budget checker" do
  it "succeeds with only a project budget entered" do
    @project.spend = nil; @project.save
    @response.project_amounts_entered?.should == true
  end
  it "succeeds if project budget not entered but a quarter budget is" do
    @project.budget = nil; @project.budget_q1 = 10; @project.save
    @response.project_amounts_entered?.should == true
  end
end

shared_examples_for "project spend checker" do
  it "succeeds with only a project spend entered" do
    @project.budget = nil; @project.save; @response.reload
    @response.project_amounts_entered?.should == true
  end
  it "succeeds if project spend not entered but a quarter spend is" do
    @project.spend = nil; @project.spend_q1 = 10 ; @project.save
    @response.project_amounts_entered?.should == true
  end
end

shared_examples_for "activity spend checker" do
  it "succeeds with only activity spend entered" do
    @activity.budget = nil; @activity.save
    @response.activity_amounts_entered?.should == true
  end
  it "succeeds if activity spend not entered but a quarter spend is" do
    @activity.spend = nil; @activity.spend_q1 = 10 ; @activity.save
    @response.activity_amounts_entered?.should == true
  end
end

shared_examples_for "activity budget checker" do
  it "succeeds with only activity budget entered" do
    @activity.spend = nil; @activity.save
    @response.activity_amounts_entered?.should == true
  end
  it "succeeds if budget not entered but a quarter budget is" do
    @activity.budget = nil; @activity.budget_q1 = 10; @activity.save
    @response.activity_amounts_entered?.should == true
  end
end

shared_examples_for "coded Activities checker" do
  it "should find no uncoded Activities" do
    @response.uncoded_activities.should be_empty
    @response.activities_coded?.should == true
  end
end

shared_examples_for "coded OtherCosts checker" do
  it "should find no uncoded Other Costs" do
    @response.uncoded_other_costs.should be_empty
    @response.other_costs_coded?.should == true
  end
end