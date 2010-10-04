require 'fastercsv'

class Reports::CodedActivityReport < Reports::ActivityReport

  attr_accessor :codes, :code_ids, :get_codes_array_method, :code_id_method, :code_class

  def initialize codes= nil, get_codes_array_method = nil, code_id_method = nil
    #add to cols only when you are doing a row join, not column join
    #dont do chaining yet, just one set of codes
    # TODO add beneficiaries as first instance of codes
   
    @codes = codes
    @get_codes_array_method = get_codes_array_method
    @code_id_method = code_id_method
    @code_ids = codes.map(&:id)
  end

  protected

  def build_header
    #print header
    header = []
    header << super()
    codes.each do |code|
      header << "#{code}"
    end
    header.flatten
  end

  # override for more complex behavior
  def get_codes_from_activity activity
    activity.send(get_codes_array_method)
  end

  def build_rows(activity)
    base_row=super(activity)
    rows = []
    act_codes = activity.send(get_codes_array_method).map(&code_id_method)
    
    row = []
    @code_ids.each do |code_id|
      if act_codes.include?(code_id)
        column_value = value_for_code_column activity, code_id
        row << column_value
      else
        row << " "
      end
    end
    rows = (base_row + row).flatten
    rows
  end

  def value_for_code_column activity, code_id
    "yes"
    #you should implement this method
    #code = activity.send(get_codes_array_method).reject {|c| c.id=code_id}
    # or maybe
    #code = code_class.find code_id
    #unless ca.amount.nil?
    #  row << ca.amount
    #else
    #  row << "#{ca.percentage}%"
    #end
  end

end

