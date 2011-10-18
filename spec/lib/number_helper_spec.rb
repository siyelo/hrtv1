require File.dirname(__FILE__) + '/../spec_helper'

describe NumberHelper do
  describe "#is_number?" do
    it "should return true if it is passed a number" do
      i = 12
      NumberHelper.is_number?(i).should be_true
    end

    it "should return true if it is passed a decimal" do
      i = 12.34
      NumberHelper.is_number?(i).should be_true
    end

    it "should return false if it is not passed a number" do
      i = "I am not a number"
      NumberHelper.is_number?(i).should be_false
    end
  end
end
