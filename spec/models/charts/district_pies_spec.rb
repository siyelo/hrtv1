require File.dirname(__FILE__) + '/../../spec_helper'
include NumberHelper

describe Charts::DistrictPies do
  describe 'Implementer charts' do
    before :each do
      basic_setup_implementer_split
      @loc = Factory :location, :short_display => 'some loc'
      @ca1 = Factory :coding_budget, :activity => @activity, :code => @loc
    end

    it "should return 11 values (top 10 + 'other') for a location" do
      12.times do |i|
        implementer = Factory(:organization)
        split = Factory(:implementer_split, :activity => @activity,
          :organization => implementer, :budget => i+2)
      end

      @values = Charts::DistrictPies::implementers(@loc, 'budget', @request.id)
      parsed_json = ActiveSupport::JSON.decode(@values)
      parsed_json.values[0].count.should == 11
      parsed_json.values[0][0][1].should == 13    # largest split
      parsed_json.values[0][9][1].should == 4     # 10th largest split
      parsed_json.values[0][10][1].should == 6.23 # remaining splits added together
    end

    it "should return the correct location" do
      activity2 = Factory :activity, :data_response => @response, :project => @project
      loc2 = Factory :location, :short_display => 'another loc'
      ca2 = Factory :coding_budget, :code => loc2, :activity => activity2

      @values = Charts::DistrictPies::implementers(loc2, 'budget', @request.id)
      parsed_json = ActiveSupport::JSON.decode(@values)
      parsed_json.values[0].count.should == 0
    end

    it "should convert to USD before sorting" do
      implementer = Factory(:organization, :currency => 'RWF')
      split = Factory(:implementer_split, :activity => @activity,
        :organization => implementer, :budget => 1)
      @currency = Factory(:currency, :conversion => 'RWF_TO_USD', :rate => 0.5)

      @values = Charts::CountryPies::implementers('budget', @request.id)
      parsed_json = ActiveSupport::JSON.decode(@values)
      parsed_json.values[0].count.should == 2
      parsed_json.values[0][1][1].should == 0.5
    end
  end

end