require 'fastercsv'

class Reports::CodedActivityReport < ActivityReport

  attr_accessible :codes, :code_ids, :get_codes_array_method, :code_id_method, :code_class

  def initialize codes= nil, get_codes_array_method = nil, code_id_method = nil
    #add to cols only when you are doing a row join, not column join
    #dont do chaining yet, just one set of codes
    # TODO add beneficiaries as first instance of codes
    code_ids = codes.map(&:id)
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

  # override this ify you need special behavior
  def add_rows_to_csv rows, csv
    if rows.first.class == Array
      rows.each {|r| add_rows_to_csv r, csv}
    else
      csv << rows
    end
  end

  def build_rows(activity)
    base_rows=super(activity)
    rows = []
    act_codes = activity.send(get_codes_array_method).map(&code_id_method)
    
    base_rows.each do |r|
      row = []
      code_ids.each do |code_id|
        if act_codes.include?(code_id)
          column_value = value_for_code_column activity, code_id
        else
          row << " "
        end
      end
      rows += r.collect {|a_base_row| (a_base_row+r).flatten}
    end
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

