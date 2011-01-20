require 'fastercsv'

class Reports::DistrictCodingsBudgetReport < Reports::RowEachCodedActivityReport
  # TODO write fix for db - district orgs dont have locations associated w them

  def initialize
    codes = Location.roots.collect{|code| code.self_and_descendants}.flatten
    super(codes, :budget_district_coding, :code_id, "District")
  end

  protected

  # TODO: if fail uncomment
  #def get_codes_from_activity activity
    #activity.send(get_codes_array_method)
  #end

  def value_for_code_column(activity, code_id)
    raise 2.to_yaml
    code_assignment = get_codes_from_activity(activity).select{|ca| ca.send(code_id_method) == code_id}
    raise "Duplicate code assignment".to_yaml if code_assignment.length > 1
    code_assignment.first.calculated_amount
  end

end

