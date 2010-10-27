module ChartsHelper

  def get_chart_id_tree(data_response, chart_type)
    "dr_#{data_response.id}_#{chart_type}_tree"
  end

  def get_chart_id_pie(data_response, chart_type)
    "dr_#{data_response.id}_#{chart_type}"
  end
end
