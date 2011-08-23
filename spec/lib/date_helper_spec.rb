require File.dirname(__FILE__) + '/../spec_helper'
include DateHelper

describe DateHelper do
  it "changes the date format from 12/12/2012 to 12-12-2012" do
    new_date = DateHelper::flexible_date_parse('12/12/2012')
    new_date.should.eql? Date.parse('12-12-2012')
  end

  it "changes the date format from 2012/03/30 to 30-03-2012" do
    new_date = DateHelper::flexible_date_parse('2012/03/30')
    new_date.should.eql? Date.parse('30-03-2012')
  end
end
