require 'spec_helper'
include CurrencyViewNumberHelper

describe CurrencyNumberHelper do
  describe "#n2cs" do
    it "should format number with currency in front" do
      n2cs("12345.67", "USD").should == "<span class=\"currency\">USD</span> 12,345.67"
    end
  end
end
