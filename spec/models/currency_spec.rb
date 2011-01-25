require File.dirname(__FILE__) + '/../spec_helper'

describe Currency do
  # ONE_HUNDRED_BILLION_DOLLARS= 100000000000.00
  # before :each do
  #   Money.add_rate("USD", "RWF", BigDecimal("597.400"))
  #   Money.add_rate("RWF", "USD", BigDecimal("1") / BigDecimal("597.400"))
  #   @a        = Factory.build(:activity)
  #   @p = @a.project
  #   @p.currency = 'RWF'
  #   @p.save
  #   @a.spend = ONE_HUNDRED_BILLION_DOLLARS
  #   @a.save
  #   @a.reload
  # end

  ### this wont work - there'll always be some rounding issues converting back.
  # Money::Bank.exchange_with() will apply a small rounding, losing precision when 
  # it stores cents 
  # Refer also: http://github.com/RubyMoney/money/issues/4#comment_224880
  #
  # it "should convert large amounts back correctly" do
  #   a = Money.new(ONE_HUNDRED_BILLION_DOLLARS, :RWF)
  #   b = Money.new(a.exchange_to(:USD).cents, "USD")
  #   b.exchange_to(:RWF).cents.should == a.cents
  # end  
  # it "should convert large activity amounts back correctly" do   
  #   @a.reload
  #   @a.save
  #   @a.new_spend.cents.should == ONE_HUNDRED_BILLION_DOLLARS
  #   @a.new_spend.currency.should == Money::Currency.new("RWF")
  #   @a.new_spend_in_usd.should ==  16739202529 # 167392032.13927 ? (xe: 167,392,025.29843 @ 0.00167392 USD (597.400 RWF))
  #   
  #   b = Money.new(@a.new_spend_in_usd, "USD")
  #   b.exchange_to(:RWF).cents.should == @a.new_spend.cents
  # end
end