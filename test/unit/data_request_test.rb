require 'test_helper'

class DataRequestTest < ActiveSupport::TestCase
  should have_many :data_responses
  should belong_to :requesting_organization

  test "creates_data_responses_for_all_orgs_on_save" do
    o1=Organization.create! :name =>"t1"
    o2=Organization.create! :name =>"t2"
    d=DataRequest.create! :title => "my test"
    assert d.data_responses.size >= 2
    d.data_responses.each do |r|
      o1 = nil if r.responding_organization == o1
      o2 = nil if r.responding_organization == o2
    end
    assert o2 == nil
    assert o1 == nil
  end
end
