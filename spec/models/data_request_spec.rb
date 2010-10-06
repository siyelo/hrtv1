require File.dirname(__FILE__) + '/../spec_helper'

describe DataRequest do
  
  describe "creating a data request record" do
    subject { Factory(:data_request) }
    it { should be_valid }
    it { should have_many :data_responses }
    it { should belong_to :requesting_organization }

    it "should remove commas from decimal fields on save" do
      [:spend, :budget, :entire_budget].each do |f|
        p = Project.new
        p.send(f.to_s+"=", "10,783,000.32")
        p.save
        p.send(f).should == 10783000.32
      end
    end
  end
end
