require File.dirname(__FILE__) + '/../spec_helper'

describe Location do
  describe "creating a location" do
    subject { Factory(:location) }
    it { should be_valid }
  end

  describe "associations" do
    it { should have_and_belong_to_many :projects }
    it { should have_and_belong_to_many :activities }
    it { should have_and_belong_to_many :organizations }
    it { should have_one :district }
  end
end
