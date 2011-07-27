require File.dirname(__FILE__) + '/../../spec_helper'

describe Purpose do
  describe "#all" do
    it "returns only Purpose codes" do
      location  = Factory(:location)
      mtef_code = Factory(:mtef_code)
      purposes  = Purpose.all
      purposes.length.should == 1
      purposes[0].should == mtef_code
    end
  end
end
