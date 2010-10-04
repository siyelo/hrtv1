require 'fastercsv'

class Reports::BeneficiaryCodedActivityReport < Reports::CodedActivityReport

  def initialize # codes= nil, get_codes_array_method = nil, code_id_method = nil
    super( Beneficiary.all, :beneficiaries, :id)
  end

  protected

  def value_for_code_column activity, code_id
    "yes"
  end

end

