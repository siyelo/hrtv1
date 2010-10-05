require 'fastercsv'

class Reports::SqlReport

  def initialize executed_query_results, select_list
    @csv_string = FasterCSV.generate do |csv|
      csv << build_header
      executed_query_results.each {|r| csv << build_row r}
    end
  end

  def csv
    @csv_string
  end

  protected

  def build_header
    select_list
  end

  def build_row row
    row = []
    select_list.each do |method|
      row << row.send(method)
    end
    row.flatten
  end
end
