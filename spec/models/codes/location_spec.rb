require File.dirname(__FILE__) + '/../../spec_helper'

describe Location do
  describe "Associations" do
    it { should have_many :organizations }
    it { should have_one :district }
  end

  it "should have alias for short_display called name()" do
    loc = Factory :location, :short_display => 'some loc'
    loc.name.should == 'some loc'
  end
end
