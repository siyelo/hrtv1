require File.dirname(__FILE__) + '/../spec_helper'

describe Currency do
  ONE_HUNDRED_BILLION_DOLLARS= 100000000000.00
  before :each do
    Money.add_rate("USD", "RWF", BigDecimal("597.400"))
    Money.add_rate("RWF", "USD", BigDecimal("1") / BigDecimal("597.400"))
    @a          = Factory.build(:activity)
    @p          = @a.project
    @p.currency = 'USD'
    @p.save
    @a.spend = ONE_HUNDRED_BILLION_DOLLARS
    @a.save
    @a.reload
  end

  ### this works when you use decimals.
  # Money::Bank.exchange_with() will apply a small rounding, losing precision when 
  # it stores cents 
  # Refer also: http://github.com/RubyMoney/money/issues/4#comment_224880
  #
  it "should convert large activity amounts back correctly" do   
    @a.reload
    @a.save
    @a.spend_in_usd.should == ONE_HUNDRED_BILLION_DOLLARS
    @p.currency = 'RWF'
    @p.save
    @a.reload
    @a.save
    @a.spend_in_usd.should == ONE_HUNDRED_BILLION_DOLLARS * (BigDecimal("1") / BigDecimal("597.400"))
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

