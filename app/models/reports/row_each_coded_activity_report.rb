require 'fastercsv'

class Reports::RowEachCodedActivityReport < Reports::CodedActivityReport

  attr_accessor :codes, :code_ids, :get_codes_array_method, :code_id_method, :code_class

  def initialize(codes = nil, get_codes_array_method = nil, code_id_method = nil, code_column_name = nil)
    super(codes, get_codes_array_method, code_id_method)
    @code_column_name = code_column_name
  end

  protected

  def build_header
    row = super
    row << @code_column_name
    row << "#{@code_column_name} Value"

    row
  end

  def build_rows(activity)
    base_rows = super(activity)
    rows = []

    base_rows.each do |base_row|
      act_codes = get_codes_from_activity(activity).map(&code_id_method)

      @code_ids.each do |code_id|
	row = []
        if act_codes.include?(code_id)
          row << display_value_for_code(code_id)
          column_value = value_for_code_column(activity, code_id)
          row << column_value
          rows << (base_row + row).flatten
        else
          # dont make a row for this code
        end
      end
    end

    rows
  end

  def display_value_for_code code_id
    codes.select {|c| c.id == code_id}.to_s
  end
end
