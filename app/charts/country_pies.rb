module CountryPies

  class << self
    include ApplicationHelper

    ### admin/district/:id/organizations
    def organizations(code_type)
      records = Organization.find :all,
        :select => "organizations.id,
                    organizations.name,
                    SUM(ca1.new_cached_amount_in_usd) as value",
      :joins => "INNER JOIN data_responses dr1 ON organizations.id = dr1.organization_id_responder
        INNER JOIN activities a1 ON dr1.id = a1.data_response_id
        INNER JOIN code_assignments ca1 ON a1.id = ca1.activity_id
          AND ca1.type = '#{code_type}'",
      :group => "organizations.id,
                 organizations.name",
      :order => "value DESC"

      prepare_organizations_pie_values(records)
    end

    def activities(coding_type)
      code_assignments = CodeAssignment.with_type(coding_type).find(:all,
        :select => "code_assignments.id, code_assignments.activity_id, activities.name AS activity_name, SUM(code_assignments.new_cached_amount_in_usd) AS value",
        :joins => :activity,
        :include => :activity,
        :group => 'code_assignments.activity_id, activities.name, code_assignments.id',
        :order => 'value DESC')

      prepare_activities_pie_values(code_assignments)
    end

    def pie(type, is_spent, level = -1)
      case type
      when 'mtef'
        codes = get_mtef_codes(level)
        coding_klass = is_spent ? CodingSpend : CodingBudget
      when 'cost_category'
        codes = CostCategory.roots
        coding_klass = is_spent ? CodingSpendCostCategorization : CodingBudgetCostCategorization
      when 'nsp'
        codes = Nsp.roots
        coding_klass = is_spent ? CodingSpend : CodingBudget
      else
        raise "Invalid type #{type}".to_yaml
      end

      load_pie(codes, coding_klass)
    end

    def activity_pie(type, is_spent, activity)
      case type
      when 'mtef'
        codes = Mtef.leaves
        coding_klass = is_spent ? CodingSpend : CodingBudget
      when 'nsp'
        codes = Nsp.leaves
        coding_klass = is_spent ? CodingSpend : CodingBudget
      when 'cost_category'
        codes = CostCategory.leaves
        coding_klass = is_spent ? CodingSpendCostCategorization : CodingBudgetCostCategorization
      else
        raise "Invalid type".to_yaml
      end

      activity_value = is_spent ? "spend" : "budget"

      get_activity_pie(coding_klass, codes, activity_value, activity)
    end

    ### admin/district/:id/organizations/:id
    def organization_pie(type, is_spent, activities)
      case type
      when 'mtef'
        codes = Mtef.leaves
        coding_type = is_spent ? "CodingSpend" : "CodingBudget"
      when 'cost_category'
        codes = CostCategory.roots
        coding_type = is_spent ? "CodingSpendCostCategorization" : "CodingBudgetCostCategorization"
      when 'nsp'
        codes = Nsp.roots
        coding_type = is_spent ? "CodingSpend" : "CodingBudget"
      else
        raise "Invalid type".to_yaml
      end

      if is_spent
        district_type  = "CodingSpendDistrict"
        activity_value = "spend"
      else
        district_type  = "CodingBudgetDistrict"
        activity_value = "budget"
      end

      prepare_organization_pie_values(coding_type, codes.map(&:id), activities, district_type, activity_value)
    end

    private

      def get_activity_pie(coding_klass, codes, activity_value, activity)
         activity_amount = activity.send(activity_value)
         coded_ok = activity_amount && activity_amount > 0
         if coded_ok
           code_assignments = coding_klass.with_code_ids(codes).with_activity(activity).select_for_pies
           prepare_pie_values(code_assignments)
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

      def prepare_organization_pie_values(coding_type, code_ids, activities, district_type, activity_value)
        code_assignments = CodeAssignment.sums_by_code_id(code_ids, coding_type, activities)
        sums             = prepare_sums(code_assignments, code_ids)

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

      def get_mtef_codes(level = -1)
        unless level == -1
          codes = []
          Mtef.each_with_level(Mtef.all){|o, lvl| codes << o if lvl == level}
        else
          codes = Mtef.leaves
        end

        return codes
      end

      def load_pie(codes, coding_klass)
        code_assignments = coding_klass.with_code_ids(codes).select_for_pies
        prepare_pie_values(code_assignments)
      end

      def prepare_pie_values(code_assignments)
        values = []
        code_assignments.each do |ca|
          values << [ca.code_name, ca.value.to_f.round(2)]
        end

        {
          :values => values,
          :names => {:column1 => 'Code name', :column2 => 'Amount'}
        }.to_json
      end

      def prepare_sums(code_assignments, code_ids)
        sums = {}
        code_ids.each do |code_id|
          assignments = code_assignments[code_id]

          if assignments.present?
            sums[code_id] = assignments.inject(0){|sum, ca| sum + ca.value.to_f}
          else
            sums[code_id] = 0
          end
        end
        sums
      end
    end
end
