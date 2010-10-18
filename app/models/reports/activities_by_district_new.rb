require 'fastercsv'

class Reports::ActivitiesByDistrictNew < Reports::CodedActivityReport
  # TODO write fix for db - district orgs dont have locations associated w them

  # codes as hash with code => [get_codes_array_method, code_id_method, value_for_code_column_method]
  def initialize # codes= nil, get_codes_array_method = nil, code_id_method = nil
    codes = []
    Location.roots.each { |c| codes << c.self_and_descendants }
    super( codes.flatten, :locations, :id)
  end

  protected

  def get_codes_from_activity activity
    activity.send(get_codes_array_method)
  end

  def value_for_code_column activity, code_id
    "yes"
  end

end

