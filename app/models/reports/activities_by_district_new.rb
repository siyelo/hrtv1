require 'fastercsv'

class Reports::ActivitiesByDistrictNew < Reports::CodedActivityReport
  # TODO write fix for db - district orgs dont have locations associated w them

  def initialize
    codes = Location.roots.collect{|code| code.self_and_descendants}.flatten
    super(codes, :locations, :id)
  end

  protected

    def get_codes_from_activity(activity)
      activity.send(get_codes_array_method)
    end

    def value_for_code_column(activity, code_id)
      "yes"
    end
end

