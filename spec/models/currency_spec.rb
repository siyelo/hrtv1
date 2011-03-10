require File.dirname(__FILE__) + '/../spec_helper'

describe Currency do
  
  describe "should used seeded currency amounts" do
    before :each do
      @dr = Factory(:data_response, :currency => 'USD')
      @project = Factory(:project, :data_response => @dr)
      @a  = Factory(:activity, :data_response => @dr,
                    :projects => [@project])
      @a.budget = 123.45
      @a.spend  = 123.45
      @a.save
      @a.reload
    end

    it "should update cached spend in USD on creation" do
      @a.spend_in_usd.should == 123.45
    end
    
    it "should handle a lesser known currency, like Albo Lek" do
      # this is tricky, since if the seed file changes, then this test fails
      # we're assuming a conversion rate of X here
      @project.currency = "DZD"
      @project.save
      @a.save
      @a.reload
      @a.spend_in_usd.should == 123.45
    end
  end
end
# == Schema Information
#
# Table name: currencies
#
#  id     :integer         primary key
#  toRWF  :decimal(, )
#  symbol :string(255)
#  name   :string(255)
#  toUSD  :decimal(, )
#

