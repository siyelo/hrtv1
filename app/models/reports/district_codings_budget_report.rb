require 'fastercsv'

class Reports::DistrictCodingsBudgetReport < Reports::CodedActivityReport

  def initialize
    codes = Location.roots.collect{|code| code.self_and_descendants}.flatten
    super(codes, :budget_district_coding, :code_id)
    @code_column_name ="District"
  end

  protected

    def build_header
      row = super

      row << @code_column_name
      row << "#{@code_column_name} Value"

      row
    end
end
