module DistrictPies
  class << self

    # index
    def activities_spent(location)
      spent_codings = location.code_assignments.with_type("CodingSpendDistrict").find(:all, 
        :select => "code_assignments.activity_id, activities.name AS activity_name, SUM(code_assignments.cached_amount) AS total",
        :joins => :activity,
        :group => 'code_assignments.activity_id',
        :order => 'cached_amount DESC')

      prepare_activities_pie_values(spent_codings, "Spent by Activities")
    end

    def activities_budget(location)
      budget_codings = location.code_assignments.with_type("CodingBudgetDistrict").find(:all, 
        :select => "code_assignments.activity_id, activities.name AS activity_name, SUM(code_assignments.cached_amount) AS total",
        :joins => :activity,
        :group => 'code_assignments.activity_id',
        :order => 'cached_amount DESC')

      prepare_activities_pie_values(budget_codings, "Budget by Activities")
    end

    def mtef_spent(location)
      load_mtef_pie( CodingSpendDistrict, CodingSpend, location, "MTEF Spend")
    end

    def mtef_budget(location)
      load_mtef_pie( CodingBudgetDistrict, CodingBudget, location, "MTEF Budget")
    end



    # show
    def load_spent_ratio_pie(location, activity)
      district_spend_coding = activity.coding_spend_district.with_location(location).find(:first)
      spend_coded_ok = district_spend_coding && activity.spend && activity.spend > 0 && district_spend_coding.calculated_amount
      if spend_coded_ok
        district_spent_ratio   = district_spend_coding.cached_amount / activity.spend # % that this district has allocated
        district_spent         = activity.spend * district_spent_ratio
        prepare_ratio_pie_values(location, activity.spend, district_spent, "Spent by Districts")
      end
    end

    def load_mtef_spent_pie(location, activity)
      district_spend_coding = activity.coding_spend_district.with_location(location).find(:first)
      spend_coded_ok = district_spend_coding && activity.spend && activity.spend > 0 && district_spend_coding.calculated_amount
      if spend_coded_ok
        district_spent_ratio   = district_spend_coding.cached_amount / activity.spend # % that this district has allocated
        district_spent         = activity.spend * district_spent_ratio
        prepare_pie_values(CodingSpend.with_code_ids(Mtef.leaves).with_activity(activity), district_spent_ratio, "MTEF Spent")
      end
    end

    def load_budget_ratio_pie(location, activity)
      district_budget_coding = activity.coding_budget_district.with_location(location).find(:first)
      budget_coded_ok = district_budget_coding && activity.budget && activity.budget > 0 && district_budget_coding.calculated_amount
      if budget_coded_ok
        district_budgeted_ratio = district_budget_coding.cached_amount / activity.budget # % that this district has allocated
        district_budgeted       = activity.budget * district_budgeted_ratio
        prepare_ratio_pie_values(location, activity.budget, district_budgeted, "Budget by Districts")
      end
    end

    def load_mtef_budget_pie(location, activity)
      district_budget_coding = activity.coding_budget_district.with_location(location).find(:first)
      budget_coded_ok = district_budget_coding && activity.budget && activity.budget > 0 && district_budget_coding.calculated_amount
      if budget_coded_ok
        district_budgeted_ratio = district_budget_coding.cached_amount / activity.budget # % that this district has allocated
        district_budgeted       = activity.budget * district_budgeted_ratio
        prepare_pie_values(CodingBudget.with_code_ids(Mtef.leaves).with_activity(activity), district_budgeted_ratio, "MTEF Budget")
      end
    end


    private

    def prepare_activities_pie_values(code_assignments, title)
      values = []
      other = 0
      code_assignments.each_with_index do |ca, index|
        if index < 5
          values << [(ca.activity_name || "No name"), ca.total]
        else
          other += ca.total.to_f
        end
      end

      values << ['Other', other]

      {
        :values => values,
        :names => {:column1 => 'Activity', :column2 => 'Amount', :title => title}
      }.to_json
    end

    def load_mtef_pie(district_klass, coding_klass, location, chart_title)
      total_in_district = district_klass.sum(:cached_amount,
                                              :conditions => ["code_id = ?", location.id])
      total_in_all_districts = district_klass.sum(:cached_amount)
      district_ratio   = total_in_district / total_in_all_districts # % that this district has allocated
      return prepare_pie_values(coding_klass.with_code_ids(Mtef.leaves).find(:all, :include => :code), district_ratio, chart_title)
    end


    def prepare_pie_values(code_assignments, ratio, title)
      values = []
      code_assignments.each do |ca|
        values << [ca.code_name, (ca.calculated_amount * ratio).round(2)]
      end

      {
        :values => values,
        :names => {:column1 => 'Code name', :column2 => 'Amount', :title => title}
      }.to_json
    end

    def prepare_ratio_pie_values(location, activity_amount, district_amount, title)
      {
        :values => [
          ["All Districts", activity_amount.round(2)],
          ["#{location.name}", district_amount.round(2)]
        ],
        :names => {:column1 => 'Code name', :column2 => 'Amount', :title => title}
      }.to_json
    end
  end
end
