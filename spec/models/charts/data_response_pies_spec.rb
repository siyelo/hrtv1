require File.dirname(__FILE__) + '/../../spec_helper'

include DelayedJobSpecHelper

describe Charts::DataResponsePies do
  describe "MTEF chart" do
    before :each do
      basic_setup_activity
      @code1 = Factory :mtef_code
      @code2 = Factory :mtef_code
    end

    it "should return even split for two root MTEFs" do
      @purpose_split1 = Factory :coding_budget, :code => @code1, :activity => @activity,
                          :percentage => 60, :cached_amount => 60
      @purpose_split2 = Factory :coding_budget, :code => @code2, :activity => @activity,
                          :percentage => 40, :cached_amount => 40
      @split          = Factory :implementer_split, :activity => @activity,
                          :budget => 100, :organization => @organization
      @assignments = Charts::DataResponsePies.data_response_pie(@response, 'CodingBudget', 'Mtef')
      @assignments.should have(2).items
      @assignments[0].name.should == @code1.name
      @assignments[1].name.should == @code2.name
      @assignments[0].value.should == 60
      @assignments[1].value.should == 40
    end

    it "should return leaf MTEFs only" do
      @code11 = Factory :mtef_code, :parent => @code1
      @purpose_split1 = Factory :coding_budget, :code => @code11, :activity => @activity,
                          :percentage => 60, :cached_amount => 60
      @purpose_split2 = Factory :coding_budget, :code => @code2, :activity => @activity,
                          :percentage => 40, :cached_amount => 40
      @split          = Factory :implementer_split, :activity => @activity,
                          :budget => 100, :organization => @organization
      @assignments = Charts::DataResponsePies.data_response_pie(@response, 'CodingBudget', 'Mtef')
      @assignments.should have(2).items
      @assignments[0].name.should == @code11.name
      @assignments[1].name.should == @code2.name
      @assignments[0].value.should == 60
      @assignments[1].value.should == 40
    end


    it "should return even split for two root MTEFs" do
      @purpose_split1 = Factory :coding_budget, :code => @code1, :activity => @activity,
                                :percentage => 60, :cached_amount => 60
      @purpose_split2 = Factory :coding_budget, :code => @code2, :activity => @activity,
                                :percentage => 40, :cached_amount => 40
      @split          = Factory :implementer_split, :activity => @activity,
                          :budget => 100, :organization => @organization
      @assignments = Charts::DataResponsePies.data_response_pie(@response, 'CodingBudget', 'Mtef')
      @assignments.should have(2).items
      @assignments[0].name.should == @code1.name
      @assignments[1].name.should == @code2.name
      @assignments[0].value.should == 60
      @assignments[1].value.should == 40
    end

    it "should return leaf MTEFs only" do
      @code11 = Factory :mtef_code, :parent => @code1
      @purpose_split1 = Factory :coding_budget, :code => @code11, :activity => @activity,
                                :percentage => 60, :cached_amount => 60
      @purpose_split2 = Factory :coding_budget, :code => @code2, :activity => @activity,
                                :percentage => 40, :cached_amount => 40
      @split          = Factory :implementer_split, :activity => @activity,
                          :budget => 100, :organization => @organization
      @assignments = Charts::DataResponsePies.data_response_pie(@response, 'CodingBudget', 'Mtef')
      @assignments.should have(2).items
      @assignments[0].name.should == @code11.name
      @assignments[1].name.should == @code2.name
      @assignments[0].value.should == 60
      @assignments[1].value.should == 40
    end

    it "should return leaf MTEFs only even if parent split has amount(s)" do
      @code11 = Factory :mtef_code, :parent => @code1
      # this is how the app currently works. Parent split nodes look like this
      @purpose_split1 = Factory :coding_budget, :code => @code1,
                          :activity => @activity, :percentage => 60, :cached_amount => 60
      @purpose_split1 = Factory :coding_budget, :code => @code11,
                          :activity => @activity, :percentage => 60, :cached_amount => 60
      @purpose_split2 = Factory :coding_budget, :code => @code2,
                          :activity => @activity, :percentage => 40, :cached_amount => 40
      @split          = Factory :implementer_split, :activity => @activity,
                          :budget => 100, :organization => @organization

      @chart_items = Charts::DataResponsePies.data_response_pie(@response, 'CodingBudget', 'Mtef')
      @chart_items.size.should == 2
      @chart_items[0].name.should == @code11.name
      @chart_items[1].name.should == @code2.name
      @chart_items[0].value.should == 60
      @chart_items[1].value.should == 40
    end
  end
end
