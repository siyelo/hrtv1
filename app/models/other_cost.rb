class OtherCost < Activity
  before_save :set_district_if_implement_is_in_one_district

  def set_district_if_implement_is_in_one_district
    #TODO
  end

  
end
