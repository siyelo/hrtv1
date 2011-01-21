require 'fastercsv'

class Reports::ActivitiesByDistrictNew < Reports::CodedActivityReport
  def initialize
    codes = Location.roots.collect{|code| code.self_and_descendants}.flatten
    super(codes, :locations, :id)
  end
end

