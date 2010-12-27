module DistrictPies


  class << self
    include ApplicationHelper

    ### admin/district/:id/organizations
    def organizations(location, code_type)
      records = Organization.find :all,
        :select => "organizations.id, organizations.name, SUM(ca1.new_cached_amount_in_usd) as value",
      :joins => "INNER JOIN data_responses dr1 ON organizations.id = dr1.organization_id_responder
        INNER JOIN activities a1 ON dr1.id = a1.data_response_id
        INNER JOIN code_assignments ca1 ON a1.id = ca1.activity_id AND ca1.type = '#{code_type}' AND ca1.code_id = #{location.id}",
      :group => "organizations.id, organizations.name",
      :order => "value DESC"

      prepare_organizations_pie_values(records)
    end

    ### admin/district/:id/activities
    def activities_spent(location)
      spent_codings = location.code_assignments.with_type("CodingSpendDistrict").find(:all,
        :select => "code_assignments.id, code_assignments.activity_id, activities.name AS activity_name, SUM(code_assignments.new_cached_amount_in_usd) AS value",
        :joins => :activity,
        :include => :activity,
        :group => 'code_assignments.activity_id, activities.name, code_assignments.id',
        :order => 'value DESC')

      prepare_activities_pie_values(spent_codings)
    end

    def activities_budget(location)
      budget_codings = location.code_assignments.with_type("CodingBudgetDistrict").find(:all,
        :select => "code_assignments.id, code_assignments.activity_id, activities.name AS activity_name, SUM(code_assignments.new_cached_amount_in_usd) AS value",
        :joins => :activity,
        :include => :activity,
        :group => 'code_assignments.activity_id, activities.name, code_assignments.id',
        :order => 'value DESC')

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
      spend_coded_ok = district_spend_coding && activity.spend && activity.spend > 0 && district_spend_coding.cached_amount
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
      budget_coded_ok = district_budget_coding && activity.budget && activity.budget > 0 && district_budget_coding.cached_amount
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

    ### admin/district/:id/organizations/:id
    def organization_mtef_spent(location, activities)
      coding_type    = "CodingSpend"
      codes          = Mtef.leaves
      district_type  = "CodingSpendDistrict"
      activity_value = "spend"
      prepare_organization_pie_values(location, coding_type, codes.map(&:id), activities, district_type, activity_value)
    end

    def organization_mtef_budget(location, activities)
      coding_type    = "CodingBudget"
      codes          = Mtef.leaves
      district_type  = "CodingBudgetDistrict"
      activity_value = "budget"
      prepare_organization_pie_values(location, coding_type, codes.map(&:id), activities, district_type, activity_value)
    end

    def organization_nsp_spent(location, activities)
      coding_type    = "CodingSpend"
      codes          = Nsp.roots
      district_type  = "CodingSpendDistrict"
      activity_value = "spend"
      prepare_organization_pie_values(location, coding_type, codes.map(&:id), activities, district_type, activity_value)
    end

    def organization_nsp_budget(location, activities)
      coding_type    = "CodingBudget"
      codes          = Nsp.roots
      district_type  = "CodingBudgetDistrict"
      activity_value = "budget"

      prepare_organization_pie_values(location, coding_type, codes.map(&:id), activities, district_type, activity_value)
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
                    activity_amount > 0 && district_coding.cached_amount
         if coded_ok
           code_assignments = coding_klass.with_code_ids(codes).with_activity(activity).select_for_pies
           ratio   = district_coding.cached_amount / activity_amount # % that this district has allocated
           prepare_pie_values(code_assignments, ratio)
         end
       end

      def prepare_activities_pie_values(code_assignments)
        values = []
        other = 0.0
        code_assignments.each_with_index do |ca, index|
          if index < 5
            values << [friendly_name(ca.activity), ca.value.to_f.round(2)]
          else
            other += ca.value.to_f
          end
        end

        values << ['Other', other.round(2)]

        {
          :values => values,
          :names => {:column1 => 'Activity', :column2 => 'Amount'}
        }.to_json
      end

      def prepare_organizations_pie_values(organizations)
        values = []
        other = 0.0
        organizations.each_with_index do |organization, index|
          if index < 5
            values << [organization.name, organization.value.to_f.round(2)]
          else
            other += organization.value.to_f
          end
        end

        values << ['Other', other.round(2)]

        {
          :values => values,
          :names => {:column1 => 'Activity', :column2 => 'Amount'}
        }.to_json
      end

      def prepare_organization_pie_values(location, coding_type, code_ids, activities, district_type, activity_value)
        code_assignments = CodeAssignment.sums_by_code_id(code_ids, coding_type, activities)
        ratios           = CodeAssignment.ratios_by_activity_id(location.id, activities, district_type, activity_value)
        sums             = prepare_sums(code_assignments, ratios, code_ids)

        values = []

        code_assignments.each_with_index do |ca, index|
          code_id = ca[0]
          if ca[1].present?
            code_name = ca[1].first.code_name
            value = sums[code_id]
            values << [code_name, value] if value
          end
        end

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
        code_assignments = coding_klass.with_code_ids(codes).select_for_pies
        district_ratio   = calculate_district_ratio(district_klass, coding_klass, location)
        return prepare_pie_values(code_assignments, district_ratio)
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
          values << [ca.code_name, (ca.value.to_f * ratio).round(2)]
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

      def prepare_sums(treemap_sums, treemap_ratios, code_ids)
        sums = {}
        code_ids.each do |code_id|
          sums[code_id] = detect_sum(treemap_sums, treemap_ratios, code_id)
        end
        sums
      end

      def detect_sum(code_assignments, treemap_ratios, code_id)
        sum = 0

        amounts = code_assignments[code_id]
        if amounts.present?
          amounts.each do |amount|
            ratios = treemap_ratios[amount.activity_id]
            if ratios.present?
              ratio = ratios.first.ratio.to_f
              sum += amount.value.to_f * ratio
            end
          end
        end

        sum
      end
    end
end
