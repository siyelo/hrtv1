require 'fastercsv'

class Reports::BudgetCodingsCodedActivityReport < Reports::CodedActivityReport

  def initialize # codes= nil, get_codes_array_method = nil, code_id_method = nil
    super( Code.roots.activity_codes, :code_assignments, :code_id)
  end

  protected

  def get_codes_array_method activity
    activity.send(get_codes_array_method).blah_blah
  end

  def value_for_code_column activity, code_id
    code_assignment = activity.send(get_codes_array_method).with_type("CodingBudget").with_code_id(code_id)
    raise "Duplicate code assignment".to_yaml if code_assignment.length > 1
    code_assignment.first.calculated_amount
  end

end

