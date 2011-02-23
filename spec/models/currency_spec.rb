require File.dirname(__FILE__) + '/../spec_helper'

describe Currency do
  ONE_HUNDRED_BILLION_DOLLARS = 100000000000.00
  before :each do
    Factory.create(:currency, :name => "dollar", :symbol => "USD",
                   :toRWF => "500", :toUSD => "1")
    Factory.create(:currency, :name => "rwandan franc", :symbol => "RWF",
                   :toRWF => "1", :toUSD => "0.002")
    @a          = Factory.build(:activity)
    @p          = @a.project
    @p.currency = 'USD'
    @p.save
    @a.spend = ONE_HUNDRED_BILLION_DOLLARS
    @a.save
    @a.reload
  end

  it "should convert large activity amounts back correctly" do
    @a.reload
    @a.save
    @a.spend_in_usd.should == ONE_HUNDRED_BILLION_DOLLARS
    @p.currency = 'RWF'
    @p.save
    @a.reload
    @a.save
    @a.spend_in_usd.should == ONE_HUNDRED_BILLION_DOLLARS / 500
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

