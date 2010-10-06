require File.dirname(__FILE__) + '/../spec_helper'

describe DataResponse do
  
  describe "basic validations" do
    subject { Factory(:data_response) }  
    it { should validate_presence_of(:data_request_id) }
    it { should validate_presence_of(:organization_id_responder) }
    it { should allow_value('2010-12-01').for(:fiscal_year_start_date) }
    it { should allow_value('2010-12-01').for(:fiscal_year_end_date) }
    it { should_not allow_value('').for(:fiscal_year_start_date) }
    it { should_not allow_value('').for(:fiscal_year_end_date) }
    it { should_not allow_value('2010-13-01').for(:fiscal_year_start_date) }
    it { should_not allow_value('2010-12-41').for(:fiscal_year_start_date) }
    it { should_not allow_value('2010-13-01').for(:fiscal_year_end_date) }
    it { should_not allow_value('2010-12-41').for(:fiscal_year_end_date) }
  end
  
  describe "date validations" do
     it "accepts start date < end date" do
       dr = Factory.build(:data_response, 
                     :fiscal_year_start_date => DateTime.new(2010, 01, 01),
                     :fiscal_year_end_date =>   DateTime.new(2010, 01, 02) )
       dr.should be_valid
     end

     it "does not accept start date > end date" do
       dr = Factory.build(:data_response, 
                     :fiscal_year_start_date => DateTime.new(2010, 01, 02),
                     :fiscal_year_end_date =>   DateTime.new(2010, 01, 01) )
       dr.should_not be_valid
     end

     it "does not accept start date = end date" do
       dr = Factory.build(:data_response, 
                     :fiscal_year_start_date => DateTime.new(2010, 01, 01),
                     :fiscal_year_end_date =>   DateTime.new(2010, 01, 01) )
       dr.should_not be_valid
     end
   end 
   
   describe "on update" do
     it "validates currency is present" do
       dr = Factory.create(:data_response, 
                     :fiscal_year_start_date => DateTime.new(2010, 01, 01),
                     :fiscal_year_end_date =>   DateTime.new(2010, 01, 02) )
       dr.currency = nil
       dr.save
       dr.should_not be_valid
       dr.errors.on(:currency).should_not be_nil
     end
   end
  
end
