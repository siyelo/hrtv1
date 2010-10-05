require 'fastercsv'

class Reports::DistrictCodingsBudgetReport < Reports::RowEachCodedActivityReport
  # TODO write fix for db - district orgs dont have locations associated w them

  def initialize # codes= nil, get_codes_array_method = nil, code_id_method = nil
    codes = []
    Location.roots.each { |c| codes << c.self_and_descendants }
    super( codes.flatten, :budget_district_coding, :code_id, "District")
  end

  protected

  def get_codes_from_activity activity
    activity.send(get_codes_array_method)
  end

  def value_for_code_column activity, code_id
    code_assignment = get_codes_from_activity(activity).select{|ca| ca.send(code_id_method) == code_id}
    raise "Duplicate code assignment".to_yaml if code_assignment.length > 1
    code_assignment.first.calculated_amount
  end

end

