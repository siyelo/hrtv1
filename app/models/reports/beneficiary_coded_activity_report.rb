require 'fastercsv'

class BeneficiaryCodedActivityReport < Reports::CodedActivityReport

#  attr_accessible :codes, :code_ids, :get_codes_array_method, :code_id_method, :code_class

  def initialize # codes= nil, get_codes_array_method = nil, code_id_method = nil
    super( Beneficiary.all, :beneficiaries, :id)
  end

  protected

#  def build_header
#    #print header
#    header = []
#    header << super()
#    codes.each do |code|
#      header << "#{code}"
#    end
#    header.flatten
#  end

#  def build_rows(activity)
#    base_row=super(activity)
#    rows = []
#    act_codes = activity.send(get_codes_array_method).map(&code_id_method)
    
#    row = []
#    code_ids.each do |code_id|
#      if act_codes.include?(code_id)
#        column_value = value_for_code_column activity, code_id
#      else
#        row << " "
#      end
#    end
#    rows = (base_row + row).flatten
#    rows
#  end

  def value_for_code_column activity, code_id
    "yes"
  end

end

