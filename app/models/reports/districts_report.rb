require 'fastercsv'

class Reports::DistrictsReport < Reports::SqlReport
  @@select_list =
    [ 'codes.short_display' ,'ca.type,' 'sum(ca.cached_amount * CASE when currencies.toRWF IS NULL THEN 580 ELSE currencies.toRWF END) as cached_amount_total' ]
  
  @@where_body = "
    FROM code_assignments ca
    INNER JOIN codes on ca.code_id = codes.id
    INNER JOIN activities on activities.id = ca.activity_id
    INNER JOIN data_responses on data_responses.id = activities.data_response_id
    LEFT JOIN currencies on currencies.symbol = data_responses.currency
    WHERE (ca.type = 'CodingBudgetDistrict' OR ca.type = 'CodingSpendDistrict')
    AND codes.type = 'Location'
    GROUP BY codes.short_display, ca.type"
  @@code_select_array = nil
  
  def initialize
    super(@@select_list, [:short_display, :type, :cached_amount_total], @@where_body, code_select_array)
  end
 
  def code_select_array
    unless @@code_select_array
      @@code_select_array = []

      #all external ids below
   #   mtef_codes = Mtef.roots
   #   hssp_strat_prog_codes = []
   #   hssp_strat_obj_codes = []
   #   nsp_codes = [ ]
      mtef_codes = [] # %w[6 8 9].collect{|e| Mtef.find_by_external_id e}.flatten
      hssp_strat_prog_codes = [] # HsspStratProg.all
      hssp_strat_obj_codes = HsspStratObj.all
      nsp_codes = [] #Nsp.all

      [ mtef_codes, nsp_codes ].each do |codes|
          #type, code_id, result_name, header_name
        codes.each do |code|
          @@code_select_array << [CodingSpend, code.id , "a#{code.id}", "#{code.class} Spend for #{code.to_s_with_external_id}"]
          @@code_select_array << [CodingBudget, code.id , "b#{code.id}", "#{code.class} Budget for #{code.to_s_with_external_id}"]
        end
      end

      [ hssp_strat_prog_codes, hssp_strat_obj_codes ].each do |codes|
          #type, code_id, result_name, header_name
        codes.each do |code|
          @@code_select_array << [HsspSpend, code.id , "c#{code.id}", "#{code.class} Spend for #{code.to_s_with_external_id}"]
          @@code_select_array << [HsspBudget, code.id , "d#{code.id}","#{code.class} Budget for #{code.to_s_with_external_id}"]
        end
      end

    else
      @@code_select_array
    end
  end

  def query
    list = @select_list + code_select_array.collect do |a|
      code_total_for_district a[0], a[1], a[2], a[3]
    end

    list = list.join ","

    @query = " SELECT
    #{list}
    #{@where_body} "

  end
end
