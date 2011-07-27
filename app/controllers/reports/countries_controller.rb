class Reports::CountriesController < Reports::BaseController
  before_filter :require_country_reports_permission
  before_filter :load_data_request_id
  before_filter :load_top_organizations_and_activities

  def show
    @budget_i_values = Charts::CountryPies::implementers('budget', @request_id)
    @spend_i_values  = Charts::CountryPies::implementers('spend', @request_id)

  end

  def classifications
    @pie          = params[:chart_type] == "pie" || params[:chart_type].blank?
    code_type     = get_code_type_and_initialize(params[:code_type])
    @chart_name   = get_chart_name(params[:code_type])

    if @pie
      if @hssp2_strat_prog || @hssp2_strat_obj
        @code_spent_values   = Charts::CountryPies::hssp2_strat_activities_pie(code_type,
                                                   @request_id, true)
        @code_budget_values  = Charts::CountryPies::hssp2_strat_activities_pie(code_type,
                                                   @request_id, false)
      else
        @code_spent_values   = Charts::CountryPies::codes_for_country_pie(code_type,
                                                   @request_id, true)
        @code_budget_values  = Charts::CountryPies::codes_for_country_pie(code_type,
                                                   @request_id, false)
      end
    else
      @code_spent_values   = Charts::CountryTreemaps::treemap(code_type, :all,
                                                   @request_id, true)
      @code_budget_values  = Charts::CountryTreemaps::treemap(code_type, :all,
                                                   @request_id, false)
    end
  end

  private

    def load_top_organizations_and_activities
      code_ids               = Mtef.roots.map(&:id)
      @top_activities        = Reports::ActivityReport.top_by_spent({
                                 :limit => 10,
                                 :code_ids => code_ids,
                                 :type => 'country',
                                 :data_request_id => @request_id
                               })
      @top_organizations     = Reports::OrganizationReport.top_by_spent({
                                 :limit => 10,
                                 :code_ids => code_ids,
                                 :type => 'country',
                                 :data_request_id => @request_id
                               })
    end

    def load_data_request_id
      @request_id = current_user.current_response.data_request.id
    end
end
