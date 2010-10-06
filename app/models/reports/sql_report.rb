require 'fastercsv'

class Reports::SqlReport
  attr_accessor :select_list, :where_body, :code_select_array
  def initialize select_list, where_body, code_select_array
    debugger
    @select_list = select_list
    @where_body = where_body
    @code_select_array = code_select_array
  end

  def csv
    unless @csv_string
      executed_query_results = Organization.find_by_sql query
      @csv_string = FasterCSV.generate do |csv|
        csv << build_header
        executed_query_results.each {|r| csv << build_row(r)}
      end
    else
      @csv_string
    end
  end

  protected

  def query
    list = @select_list + code_select_array.collect do |a|
      code_total_for a[0], a[1], a[2], a[3]
    end

    list = list.join ","

    @query = " SELECT
    #{list}
    #{@where_body} "

  end

  def build_header
    (select_list + code_select_array.collect{|c| c[3]}).flatten.join ","
  end

  def build_row row
    row = []
    debugger
    select_list.each do |method|
      row << row.send(method)
    end
    code_select_array.each do |method|
      row << row.send(result_name)
    end
    row.flatten
  end

  def code_total_for type, code_id, result_name, header_name
    "( select sum(code_assignments.cached_amount)
       FROM code_assignments
       INNER JOIN activities on activities.id = code_assignments.activity_id
       WHERE activities.provider_id = organizations.id
       AND code_assignments.type = '#{type}'
       AND code_assignments.code_id = #{code_id} ) as #{result_name}"
  end
end
