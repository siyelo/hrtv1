class ChartsController < ApplicationController

  def data_response_pie
    @data_response = DataResponse.available_to(current_user).find(params[:id])
    @assignments = @data_response.activity_coding(params[:codings_type], params[:code_type])

    send_data get_csv_string(@assignments), :type => 'text/csv; charset=iso-8859-1; header=present'
  end

  def project_pie
    @project = Project.available_to(current_user).find(params[:id])
    @assignments = @project.activity_coding(params[:codings_type], params[:code_type])

    send_data get_csv_string(@assignments), :type => 'text/csv; charset=iso-8859-1; header=present'
  end

  def data_response_treemap
    data_response = DataResponse.find(params[:id])
    
    respond_to do |format|
      format.json { render :json => get_data_response_data_rows(data_response, params[:chart_type]) }
    end
  end

  def project_treemap
    project = Project.find(params[:id])
    
    respond_to do |format|
      format.json { render :json => get_project_data_rows(project, params[:chart_type]) }
    end
  end

  def activity_treemap
    activity = Activity.find(params[:id])
    
    respond_to do |format|
      format.json { render :json => get_activity_data_rows(activity, params[:chart_type]) }
    end
  end

  private

  # csv format for AM pie chart:
  # title, value, ?, ?, ?, description
  def get_csv_string(records)
    other = 0
    csv_string = FasterCSV.generate do |csv|
      records.each_with_index do |record, index|
        if index < 10
          csv << [first_n_words(h(record.name), 3), record.value.to_f, nil, nil, nil, h(record.name) ]
        else
          other += record.value.to_f
        end
      end
      csv << ['Other', other, nil, nil, nil, 'Other']
    end
    csv_string
  end

  def h(str)
    if str
      str.gsub!(',', '  ')
      str.gsub!("\n", '  ')
      str.gsub!("\t", '  ')
      str.gsub!("\015", "  ") # damn you ^M
    end
    str
  end

  def first_n_words(string, n)
    string.split(' ').slice(0,n).join(' ') + '...'
  end

  def get_data_response_data_rows(data_response, chart_type)
    case chart_type
    when 'mtef_budget'
      codes = Mtef.all
      roots = Mtef.roots
      data_rows = Code.treemap_for_codes(roots, codes, "CodingBudget", data_response.activities)
      return data_rows
    when 'mtef_spend'
      codes = Mtef.all
      roots = Mtef.roots
      data_rows = Code.treemap_for_codes(roots, codes, "CodingSpend", data_response.activities)
      return data_rows
    when 'nsp_budget'
      codes = Nsp.all
      roots = Nsp.roots
      data_rows = Code.treemap_for_codes(roots, codes, "CodingBudget", data_response.activities)
      return data_rows
    when 'nsp_spend'
      codes = Nsp.all
      roots = Nsp.roots
      data_rows = Code.treemap_for_codes(roots, codes, "CodingSpend", data_response.activities)
      return data_rows
    else
      raise "Wrong chart type".to_yaml
    end
  end

  def get_project_data_rows(project, chart_type)
    data_rows = []
    data_rows << ['All Codes',nil,0,0]

    case chart_type
    when 'mtef_budget'
    when 'mtef_spend'
    when 'nsp_budget'
    when 'nsp_spend'
    else
      raise "Wrong chart type".to_yaml
    end

    return data_rows
  end

  def get_activity_data_rows(activity, chart_type)
    data_rows = []
    data_rows << ['All Codes',nil,0,0]

    case chart_type
    when 'budget_coding'
    when 'budget_districts'
    when 'budget_cost_categorization'
    when 'spend_coding'
    when 'spend_districts'
    when 'spend_cost_categorization'
    else
      raise "Wrong chart type".to_yaml
    end

    return data_rows
  end
end
