module DistrictPies


  class << self
    include ApplicationHelper

    ### index
    def activities_spent(location)
      spent_codings = location.code_assignments.with_type("CodingSpendDistrict").find(:all,
        :select => "code_assignments.activity_id, activities.name AS activity_name, SUM(code_assignments.cached_amount) AS cached_amount",
        :joins => :activity,
        :group => 'code_assignments.activity_id, activities.name',
        :order => 'cached_amount DESC')

      prepare_activities_pie_values(spent_codings)
    end

    def activities_budget(location)
      budget_codings = location.code_assignments.with_type("CodingBudgetDistrict").find(:all,
        :select => "code_assignments.activity_id, activities.name AS activity_name, SUM(code_assignments.cached_amount) AS cached_amount",
        :joins => :activity,
        :group => 'code_assignments.activity_id, activities.name',
        :order => 'cached_amount DESC')

      prepare_activities_pie_values(budget_codings)
    end

    def activities_nsp_spent(location)
      load_nsp_pie(CodingSpendDistrict, CodingSpend, location)
    end

    def activities_nsp_budget(location)
      load_nsp_pie(CodingBudgetDistrict, CodingBudget, location)
    end

    def activities_mtef_spent(location, level = -1)
      load_mtef_pie(CodingSpendDistrict, CodingSpend, location, level)
    end

    def activities_mtef_budget(location, level = -1)
      load_mtef_pie(CodingBudgetDistrict, CodingBudget, location, level)
    end


    ### show
    def activity_spent_ratio(location, activity)
      district_spend_coding = activity.coding_spend_district.with_location(location).find(:first)
      spend_coded_ok = district_spend_coding && activity.spend && activity.spend > 0 && district_spend_coding.calculated_amount
      if spend_coded_ok
        district_spent_ratio   = district_spend_coding.cached_amount / activity.spend # % that this district has allocated
        district_spent         = activity.spend * district_spent_ratio
        prepare_ratio_pie_values(location, activity.spend, district_spent)
      end
    end

    def activity_nsp_spent(location, activity)
      coding_klass = CodingSpend
      codes = Nsp.leaves
      activity_spent(location, activity, coding_klass, codes)
    end

    def activity_mtef_spent(location, activity)
      coding_klass = CodingSpend
      codes = Mtef.leaves
      activity_spent(location, activity, coding_klass, codes)
    end

    def activity_budget_ratio(location, activity)
      district_budget_coding = activity.coding_budget_district.with_location(location).find(:first)
      budget_coded_ok = district_budget_coding && activity.budget && activity.budget > 0 && district_budget_coding.calculated_amount
      if budget_coded_ok
        district_budgeted_ratio = district_budget_coding.cached_amount / activity.budget # % that this district has allocated
        district_budgeted       = activity.budget * district_budgeted_ratio
        prepare_ratio_pie_values(location, activity.budget, district_budgeted)
      end
    end

    def activity_nsp_budget(location, activity)
      coding_klass = CodingBudget
      codes = Nsp.leaves
      activity_spent(location, activity, coding_klass, codes)
    end

    def activity_mtef_budget(location, activity)
      coding_klass = CodingBudget
      codes = Mtef.leaves
      activity_spent(location, activity, coding_klass, codes)
    end

    private

      def activity_spent(location, activity, coding_klass, codes)
         if coding_klass == CodingBudget
           district_coding = activity.coding_budget_district.with_location(location).find(:first)
           activity_amount = activity.budget
         else
           district_coding = activity.coding_spend_district.with_location(location).find(:first)
           activity_amount = activity.spend
         end
         coded_ok = district_coding && activity_amount &&
                    activity_amount > 0 && district_coding.calculated_amount
         if coded_ok
           ratio   = district_coding.cached_amount / activity_amount # % that this district has allocated
           prepare_pie_values(coding_klass.with_code_ids(codes).with_activity(activity), ratio)
         end
       end

      def prepare_activities_pie_values(code_assignments)
        values = []
        other = 0
        code_assignments.each_with_index do |ca, index|
          if index < 5
            values << [friendly_name(ca.activity), ca.cached_amount.to_f.round(2)]
          else
            other += ca.cached_amount.to_f
          end
        end

        values << ['Other', other.round(2)]

        {
          :values => values,
          :names => {:column1 => 'Activity', :column2 => 'Amount'}
        }.to_json
      end

      def load_nsp_pie(district_klass, coding_klass, location)
        codes = Nsp.roots
        return load_pie(codes, district_klass, coding_klass, location, -1)
      end

      def load_mtef_pie(district_klass, coding_klass, location, level = -1)
        unless level == -1
          codes = []
          Mtef.each_with_level(Mtef.all){|o, lvl| codes << o if lvl == level}
        else
          codes = Mtef.leaves
        end
        return load_pie(codes, district_klass, coding_klass, location, level = -1)
      end

      def load_pie(codes, district_klass, coding_klass, location, level = -1)
        district_ratio   = calculate_district_ratio(district_klass, coding_klass, location)

        return prepare_pie_values(coding_klass.with_code_ids(codes).find(:all,
          :select => "code_assignments.code_id, SUM(code_assignments.cached_amount) AS cached_amount",
          :include => :code,
          :group => 'code_assignments.code_id'), district_ratio)
      end

      # % that this district has allocated
      def calculate_district_ratio(district_klass, coding_klass, location)
        total_in_district = district_klass.sum(:cached_amount,
                                               :conditions => ["code_id = ?", location.id])
        total_in_all_districts = district_klass.sum(:cached_amount)
        return total_in_district / total_in_all_districts
      end

      def prepare_pie_values(code_assignments, ratio)
        values = []
        code_assignments.each do |ca|
          values << [ca.code_name, (ca.calculated_amount * ratio).round(2)]
        end

        {
          :values => values,
          :names => {:column1 => 'Code name', :column2 => 'Amount'}
        }.to_json
      end

      def prepare_ratio_pie_values(location, activity_amount, district_amount)
        {
          :values => [
            ["#{location.name}", district_amount.round(2)],
            ["Other Districts", activity_amount.round(2)]

          ],
          :names => {:column1 => 'Code name', :column2 => 'Amount'}
        }.to_json
      end
    end
end
