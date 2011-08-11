shared_examples_for "activity spend checker" do
  it "succeeds with only activity spend entered" do
    @activity.budget = nil; @activity.save
    @response.activity_amounts_entered?.should == true
  end
end

shared_examples_for "activity budget checker" do
  it "succeeds with only activity budget entered" do
    @activity.spend = nil; @activity.save
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
