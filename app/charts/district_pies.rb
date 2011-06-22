module Charts::DistrictPies
  extend ApplicationHelper
  extend Charts::HelperMethods

  class << self

    ### admin/district/:id/organizations
    def organizations(location, code_type)
      records = Organization.find :all,
        :select => "organizations.id,
          organizations.name,
          SUM(ca1.cached_amount_in_usd) as value",
        :joins => "INNER JOIN data_responses dr1 ON organizations.id = dr1.organization_id
          INNER JOIN activities a1 ON dr1.id = a1.data_response_id
          INNER JOIN code_assignments ca1 ON a1.id = ca1.activity_id
            AND ca1.type = '#{code_type}'
            AND ca1.code_id = #{location.id}",
      :group => "organizations.id,
                 organizations.name",
      :order => "value DESC"

      prepare_pie_values_json(records)
    end

    def ultimate_funding_sources(location, amount_type, request_id)
      records = FundingStream.find :all,
        :select => "organizations.id,
          organizations.name,
          SUM(funding_streams.#{amount_type}_in_usd) as value",
        :joins => "INNER JOIN organizations ON 
                    funding_streams.organization_ufs_id = organizations.id
                   INNER JOIN projects ON projects.id = funding_streams.project_id
                   INNER JOIN data_responses ON 
                    data_responses.id = projects.data_response_id AND data_responses.data_request_id = #{request_id}
                   INNER JOIN activities ON activities.project_id = projects.id
                   INNER JOIN code_assignments ON activities.id = code_assignments.activity_id
                     AND code_assignments.code_id = #{location.id}",
        :group => "organizations.id,
                   organizations.name",
        :order => "value DESC"

      prepare_pie_values_json(records)
    end

    def financing_agents(location, amount_type, request_id)
      records = FundingStream.find :all,
        :select => "organizations.id,
          organizations.name,
          SUM(funding_streams.#{amount_type}_in_usd) as value",
        :joins => "INNER JOIN organizations ON 
                    funding_streams.organization_fa_id = organizations.id
                   INNER JOIN projects ON projects.id = funding_streams.project_id
                   INNER JOIN data_responses ON 
                    data_responses.id = projects.data_response_id AND data_responses.data_request_id = #{request_id}
                   INNER JOIN activities ON activities.project_id = projects.id
                   INNER JOIN code_assignments ON activities.id = code_assignments.activity_id
                     AND code_assignments.code_id = #{location.id}",
        :group => "organizations.id,
                   organizations.name",
        :order => "value DESC"

      prepare_pie_values_json(records)
    end

    def implementers(location, amount_type, request_id)
      records = FundingStream.find :all,
        :select => "organizations.id,
          organizations.name,
          SUM(funding_streams.#{amount_type}_in_usd) as value",
        :joins => "INNER JOIN projects ON projects.id = funding_streams.project_id
                   INNER JOIN data_responses ON 
                    data_responses.id = projects.data_response_id AND data_responses.data_request_id = #{request_id}
                   INNER JOIN activities ON activities.project_id = projects.id
                   INNER JOIN organizations ON activities.provider_id = organizations.id
                   INNER JOIN code_assignments ON activities.id = code_assignments.activity_id
                     AND code_assignments.code_id = #{location.id}",
        :group => "organizations.id,
                   organizations.name",
        :order => "value DESC"

      prepare_pie_values_json(records)
    end

    ### admin/district/:id/activities
    def activities(location, coding_type)
      spent_codings = location.code_assignments.with_type(coding_type).find(:all,
        :select => "code_assignments.id,
                    code_assignments.activity_id,
                    activities.name AS activity_name,
                    SUM(code_assignments.cached_amount_in_usd) AS value",
        :joins => :activity,
        :include => :activity,
        :group => 'code_assignments.activity_id,
                   activities.name,
                   code_assignments.id',
        :order => 'value DESC')

      prepare_activities_pie_values(spent_codings)
    end

    def pie(request_id, location, code_type, is_spent, level = -1)
      codes = get_codes(code_type)
      coding_type = get_coding_type(code_type, is_spent)

      district_klass = is_spent ? CodingSpendDistrict : CodingBudgetDistrict
      load_pie(request_id, codes, district_klass, coding_type, location)
    end

    def hssp2_strat_activities_pie(location, code_type, is_spent, data_request_id, activities = nil)
      column_name = get_hssp2_column_name(code_type)
      coding_type = get_hssp2_coding_type(is_spent)
      district_klass = is_spent ? CodingSpendDistrict : CodingBudgetDistrict
      
      if activities == nil
        # district all activities
        activity_ids = location.code_assignments.find(:all, 
                         :select => 'DISTINCT("activity_id")').map(&:activity_id)
      else
        # district selected activities
        activity_ids = activities.map(&:id)
      end

      code_assignments = CodeAssignment.find(:all,
        :select => "codes.id as code_id,
                    codes.parent_id as parent_id,
                    codes.short_display,
                    codes.#{column_name} AS name,
                    SUM(code_assignments.cached_amount) AS value",
        :conditions => ["code_assignments.type = ?
                        AND activities.id IN (?)", 
                        coding_type, activity_ids],
        :joins => "INNER JOIN codes ON
                            codes.id = code_assignments.code_id
                          INNER JOIN activities ON
                            activities.id = code_assignments.activity_id
                          INNER JOIN projects ON
                           projects.id = activities.project_id
                          INNER JOIN data_responses ON
                           data_responses.id = projects.data_response_id
                          INNER JOIN data_requests ON
                           data_requests.id = data_responses.data_request_id AND
                           data_requests.id = #{data_request_id}",
                           
        :group => "codes.short_display, codes.id, codes.parent_id, codes.#{column_name}",
        :order => 'value DESC')


      code_assignments = remove_parent_code_assignments(code_assignments)
      district_ratio   = calculate_district_ratio(district_klass, location)
      build_pie_values_json(get_summed_code_assignments(code_assignments, district_ratio))
    end

    def activity_pie(location, activity, code_type, is_spent)
      code_klass_string = get_code_klass_string(code_type)
      coding_type       = get_coding_type(code_type, is_spent)
      district_type     = is_spent ? "CodingSpendDistrict" : "CodingBudgetDistrict"
      activity_amount   = is_spent ? activity.spend_in_usd : activity.budget_in_usd

      district_coding   = CodeAssignment.with_activity(activity.id).with_type(district_type).with_code_id(location.id).last
      coded_ok          = district_coding && district_coding.cached_amount_in_usd &&
                          activity_amount && activity_amount > 0

      if coded_ok
        code_assignments = get_code_assignments_for_codes_pie(code_klass_string, coding_type, [activity])
        ratio   = district_coding.cached_amount_in_usd / activity_amount # % that this district has allocated
        prepare_pie_values(code_assignments, ratio)
      end
    end

    ### show
    def activity_spent_ratio(location, activity)
      district_spend_coding = activity.coding_spend_district.with_code_id(location.id).last
      spend_coded_ok = district_spend_coding && activity.spend_in_usd && activity.spend_in_usd > 0 && district_spend_coding.cached_amount_in_usd
      if spend_coded_ok
        district_spent_ratio   = district_spend_coding.cached_amount_in_usd / activity.spend_in_usd # % that this district has allocated
        district_spent         = activity.spend_in_usd * district_spent_ratio
        prepare_ratio_pie_values(location, activity.spend_in_usd, district_spent)
      end
    end

    def activity_budget_ratio(location, activity)
      # TODO
      district_budget_coding = activity.coding_budget_district.with_code_id(location.id).last
      budget_coded_ok = district_budget_coding && activity.budget_in_usd && activity.budget_in_usd > 0 && district_budget_coding.cached_amount_in_usd
      if budget_coded_ok
        district_budgeted_ratio = district_budget_coding.cached_amount_in_usd / activity.budget_in_usd # % that this district has allocated
        district_budgeted       = activity.budget_in_usd * district_budgeted_ratio
        prepare_ratio_pie_values(location, activity.budget_in_usd, district_budgeted)
      end
    end

    ### admin/district/:id/organizations/:id
    def organization_pie(location, activities, code_type, is_spent)
      #codes = get_codes(code_type)
      coding_type = get_coding_type(code_type, is_spent)

      if is_spent
        district_type  = "CodingSpendDistrict"
        activity_value = "spend_in_usd"
      else
        district_type  = "CodingBudgetDistrict"
        activity_value = "budget_in_usd"
      end

      code_klass = get_code_klass(code_type)
      prepare_organization_pie_values(location, coding_type, code_klass.all.map(&:id), activities, district_type, activity_value)
    end

    private
      def prepare_activities_pie_values(code_assignments)
        values = []
        other = 0.0
        code_assignments.each_with_index do |ca, index|
          if index < 5
            values << [friendly_name(ca.activity), ca.value.to_f.round(2)] #value is the aggregate column from the sql
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

      def prepare_organization_pie_values(location, coding_type, code_ids, activities, district_type, activity_value)
        code_assignments = CodeAssignment.with_code_ids(code_ids).with_type(coding_type).with_activities(activities).find(:all,
      :select => "codes.id as code_id,
                  codes.parent_id as parent_id,
                  code_assignments.activity_id,
                  codes.short_display AS my_name,
                  SUM(code_assignments.cached_amount_in_usd) AS value",
      :joins => [:activity, :code],
      :group => "codes.short_display,
                 codes.id,
                 codes.parent_id,
                 code_assignments.activity_id",
      :order => 'value DESC')
        code_assignments_by_activity = code_assignments.group_by{|ca| ca.activity_id}
        ratios_by_activity = CodeAssignment.ratios_by_activity_id(location.id, activities, district_type, activity_value)

        code_totals = {}
        code_assignments_by_activity.each do |activity_id, code_assignments|
          code_assignments = remove_parent_code_assignments(code_assignments)
          code_assignments.each do |code_assignment|
            if ratios_by_activity[activity_id].present?
              ratio = ratios_by_activity[activity_id].first.ratio.to_f
              current_value = code_totals[code_assignment.my_name] || 0
              code_totals[code_assignment.my_name] = current_value + code_assignment.value.to_f * ratio
            end
          end
        end

        values = []
        code_totals.each do |code_name, value|
          values << [code_name, value]
        end

        {
          :values => values,
          :names => {:column1 => 'Activity', :column2 => 'Amount'}
        }.to_json
      end
      
      def load_pie(request_id, codes, district_klass, coding_type, location)
        code_assignments = CodeAssignment.with_type(coding_type).with_code_ids(codes).with_request(request_id).select_for_pies
        district_ratio   = calculate_district_ratio(district_klass, location)
        return prepare_pie_values(code_assignments, district_ratio)
      end

      # % that this district has allocated
      def calculate_district_ratio(district_klass, location)
        total_in_district = district_klass.sum(:cached_amount,
                                               :conditions => ["code_id = ?", location.id])
        total_in_all_districts = district_klass.sum(:cached_amount)

        total_in_all_districts > 0 ? total_in_district / total_in_all_districts : 0
      end

      def prepare_pie_values(code_assignments, ratio)
        values = []
        code_assignments.each do |ca|
          values << [ca.code.short_display, (ca.value.to_f * ratio).round(2)]
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
            ["Other Districts", activity_amount.round(2) - district_amount.round(2)]

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
