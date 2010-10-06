require 'fastercsv'

class Reports::ActivitiesByHssp2 < Reports::CodedActivityReport
  # TODO write fix for db - district orgs dont have locations associated w them

  # codes as hash with code => [get_codes_array_method, code_id_method, value_for_code_column_method]
  def initialize # codes= nil, get_codes_array_method = nil, code_id_method = nil
    codes = []
    codes = HsspStratProg.all
    super( codes, :budget_stratprog_coding, :code_id)
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

