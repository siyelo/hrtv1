require 'fastercsv'

class Reports::DistrictsReportWithImplementers < Reports::SqlReport
  @@select_list =
    [ 'codes.short_display' ,'ca.type,' 'sum(ca.cached_amount * CASE when currencies.toRWF IS NULL THEN 580 ELSE currencies.toRWF END) as cached_amount_total, organizations.name' ]
  
  @@where_body = "
    FROM code_assignments ca
    INNER JOIN codes on ca.code_id = codes.id
    INNER JOIN activities on activities.id = ca.activity_id
    INNER JOIN organizations on organizations.id = activities.provider_id
    INNER JOIN data_responses on data_responses.id = activities.data_response_id
    LEFT JOIN currencies on currencies.symbol = data_responses.currency
    WHERE (ca.type = 'CodingBudgetDistrict' OR ca.type = 'CodingSpendDistrict')
    AND codes.type = 'Location'
    GROUP BY codes.short_display, ca.type, organizations.name"
  @@code_select_array = nil
  
  def initialize
    super(@@select_list, [:short_display, :type, :cached_amount_total, :name], @@where_body, [])
  end
 
  def query
    list = @select_list 
    
    list = list.join ","

    @query = " SELECT
    #{list}
    #{@where_body} "

  end
end
