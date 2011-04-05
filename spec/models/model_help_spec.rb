require File.dirname(__FILE__) + '/../spec_helper'

describe ModelHelp do

  describe "validations" do
    subject { Factory(:model_help) }
    it { should be_valid }
  end

  describe "associations" do
    it { should have_many :comments }
    it { should have_many :field_help }
  end

  describe "counter cache" do
    context "comments cache" do
      before :each do
        @commentable = Factory.create(:model_help)
      end

      it_should_behave_like "comments_cacher"
    end
  end

  describe "#name" do
    it "returns model_name" do
      model_help = Factory.create(:model_help, :model_name => 'Model Name')
      model_help.name.should == 'Model Name'
    end
  end
end

# == Schema Information
#
# Table name: model_helps
#
#  id             :integer         primary key
#  model_name     :string(255)
#  short          :string(255)
#  long           :text
#  created_at     :timestamp
#  updated_at     :timestamp
#  comments_count :integer         default(0)
#

