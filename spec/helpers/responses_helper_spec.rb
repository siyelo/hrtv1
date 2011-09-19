require 'spec_helper'

describe ResponsesHelper do
  describe "othercosts class" do
    before :each do
      basic_setup_project
    end

    it "should return an info class if there are no other costs entered" do
      @response.stub(:other_costs_entered?) { false }
      helper.other_costs_class(@response).should == "info"
    end

    it "should return ready if all other costs have been coded" do
      @response.stub(:other_costs_entered?) { true }
      helper.other_costs_class(@response).should == "ready"
    end
  end
end
