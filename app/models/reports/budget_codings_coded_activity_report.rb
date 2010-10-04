require 'fastercsv'

class BudgetCodingsCodedActivityReport < Reports::CodedActivityReport

  def initialize # codes= nil, get_codes_array_method = nil, code_id_method = nil
    super( Code.roots.activity_codes, :code_assignments, :code_id)
  end

  protected

  def get_codes_array_method activity
    activity.send(get_codes_array_method).blah_blah
  end

  def value_for_code_column activity, code_id
    code_assignment = activity.send(get_codes_array_method).reject {|coding| coding.send(code_id_method) == code_id}
    code_assignment.calculated_amount
  end

end

