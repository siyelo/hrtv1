module PrepareCharts
  def get_code_type_and_initialize(code_type)
    case code_type
    when 'mtef', '', nil
      @mtef = true
      code_type = 'mtef'
    when 'cost_category'
      @cost_category = true
    when 'nsp'
      @nsp = true
    when 'hssp2_strat_prog'
      @hssp2_strat_prog = true
    when 'hssp2_strat_obj'
      @hssp2_strat_obj = true
    else
      raise "Invalid code type #{code_type}"
    end

    code_type
  end

  def get_chart_name(code_type)
    case code_type
    when 'mtef'
      'MTEF'
    when 'cost_category'
      'Inputs'
    when 'nsp', '', nil
      'NSP'
    when 'hssp2_strat_prog'
      'HSSP2 Strat Prog'
    when 'hssp2_strat_obj'
      'HSSP2 Strat Obj'
    else
      raise "Invalid code type #{code_type}"
    end
  end

  def load_dashboard_charts
    @organization   = current_user.organization
    code_type       = get_code_type_and_initialize(params[:code_type])
    @chart_name     = get_chart_name(params[:code_type])
    activities      = @organization.dr_activities
    data_request_id = current_user.current_response.data_request.id
    if @hssp2_strat_prog || @hssp2_strat_obj
      @code_spent_values  = Charts::CountryPies::hssp2_strat_activities_pie(code_type, data_request_id, true, activities)
      @code_budget_values = Charts::CountryPies::hssp2_strat_activities_pie(code_type, data_request_id, false, activities)
    else
      @code_spent_values  = Charts::CountryPies::codes_for_activities_pie(code_type, data_request_id, activities, true)
      @code_budget_values = Charts::CountryPies::codes_for_activities_pie(code_type, data_request_id, activities, false)
    end
  end
end
