require 'fastercsv'

class Reports::DistrictCodingsBudgetReport < Reports::RowEachCodedActivityReport

  def initialize # codes= nil, get_codes_array_method = nil, code_id_method = nil
    codes = []
    Location.roots.each { |c| codes << c.self_and_descendants }
    super( codes.flatten, :code_assignments, :code_id, "District")
  end

  protected

  def get_codes_from_activity activity
    activity.send(get_codes_array_method).with_type("CodingBudgetDistrict")
  end

  def value_for_code_column activity, code_id
    code_assignment = get_codes_from_activity(activity).with_code_id(code_id)
    raise "Duplicate code assignment".to_yaml if code_assignment.length > 1
    code_assignment.first.calculated_amount
  end

end

