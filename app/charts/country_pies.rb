module Charts::CountryPies
  extend Charts::HelperMethods

  class << self
    ### admin/district/:id/organizations
    def organizations_pie(code_type, data_request_id)
      records = Organization.find :all,
        :select => "organizations.id,
                    organizations.name as name,
                    SUM(ca1.cached_amount_in_usd) as value",
      :joins => "INNER JOIN data_responses dr1 ON organizations.id = dr1.organization_id
        INNER JOIN data_requests ON
          data_requests.id = dr1.data_request_id AND
          data_requests.id = #{data_request_id}
        INNER JOIN activities a1 ON dr1.id = a1.data_response_id
        INNER JOIN code_assignments ca1 ON a1.id = ca1.activity_id
          AND ca1.type = '#{code_type}'",
      :group => "organizations.id,
                 organizations.name",
      :order => "value DESC"

      prepare_pie_values_json(records)
    end

    def ultimate_funding_sources(amount_type, data_request_id)
      records = FundingStream.find :all,
        :select => "organizations.id,
          organizations.name,
          SUM(funding_streams.#{amount_type}_in_usd) as value",
        :joins => "INNER JOIN organizations ON
                    funding_streams.organization_ufs_id = organizations.id
                   INNER JOIN projects ON
                    projects.id = funding_streams.project_id
                   INNER JOIN data_responses ON
                    data_responses.id = projects.data_response_id
                   INNER JOIN data_requests ON
                    data_requests.id = data_responses.data_request_id AND
                    data_requests.id = #{data_request_id}",
        :group => "organizations.id,
                   organizations.name",
        :order => "value DESC",
        :conditions => []

      prepare_pie_values_json(records)
    end

    def financing_agents(amount_type, data_request_id)
      records = FundingStream.find :all,
        :select => "organizations.id,
          organizations.name,
          SUM(funding_streams.#{amount_type}_in_usd) as value",
        :joins => "INNER JOIN organizations ON
                    funding_streams.organization_fa_id = organizations.id
                   INNER JOIN projects ON
                    projects.id = funding_streams.project_id
                   INNER JOIN data_responses ON
                    data_responses.id = projects.data_response_id
                   INNER JOIN data_requests ON
                    data_requests.id = data_responses.data_request_id AND
                    data_requests.id = #{data_request_id}",
        :group => "organizations.id,
                   organizations.name",
        :order => "value DESC"

      prepare_pie_values_json(records)
    end

    def implementers(amount_type, data_request_id)
      records = FundingStream.find :all,
        :select => "organizations.id,
          organizations.name,
          SUM(funding_streams.#{amount_type}_in_usd) as value",
        :joins => "INNER JOIN projects ON
                    projects.id = funding_streams.project_id
                   INNER JOIN data_responses ON
                    data_responses.id = projects.data_response_id
                   INNER JOIN data_requests ON
                    data_requests.id = data_responses.data_request_id AND
                    data_requests.id = #{data_request_id}
                   INNER JOIN activities ON activities.project_id = projects.id
                   INNER JOIN organizations ON activities.provider_id = organizations.id",
        :group => "organizations.id,
                   organizations.name",
        :order => "value DESC"

      prepare_pie_values_json(records)
    end

    def activities_pie(coding_type, data_request_id)
      code_assignments = CodeAssignment.with_type(coding_type).find(:all,
        :select => "code_assignments.id,
                    code_assignments.activity_id,
                    COALESCE(activities.name, activities.description) AS name_or_descr,
                    SUM(code_assignments.cached_amount_in_usd) AS value",
        :joins => "INNER JOIN activities ON
                     activities.id = code_assignments.activity_id
                   INNER JOIN projects ON
                    projects.id = activities.project_id
                   INNER JOIN data_responses ON
                    data_responses.id = projects.data_response_id
                   INNER JOIN data_requests ON
                    data_requests.id = data_responses.data_request_id AND
                    data_requests.id = #{data_request_id}",
        :include => :activity,
        :group => 'code_assignments.id,
                   code_assignments.activity_id,
                   name_or_descr',
        :order => 'value DESC')

      prepare_pie_values_json(code_assignments)
    end

    def codes_for_country_pie(code_type, data_request_id, is_spent)
      codes = get_codes(code_type)
      coding_type = get_coding_type(code_type, is_spent)

      code_assignments = CodeAssignment.with_type(coding_type).with_code_ids(codes).find(:all,
              :select => "code_assignments.code_id,
                codes.short_display as name,
                SUM(code_assignments.cached_amount_in_usd) AS value",
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
              :group => 'code_assignments.code_id,
                         codes.short_display',
              :order => 'value DESC')

      prepare_pie_values_json(code_assignments)
    end

    def codes_for_activities_pie(code_type, data_request_id, activities, is_spent)
      code_klass_string = get_code_klass_string(code_type)
      coding_type       = get_coding_type(code_type, is_spent)

      code_assignments = CodeAssignment.find(:all,
        :select => "codes.id as code_id,
                    codes.parent_id as parent_id,
                    codes.short_display AS name,
                    SUM(code_assignments.cached_amount) AS value",
        :conditions => ["codes.type = ?
          AND code_assignments.type = ?
          AND activities.id IN (?)",
          code_klass_string, coding_type, activities.map(&:id)],
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
        :group => "codes.short_display, codes.id, codes.parent_id",
        :order => 'value DESC')

      code_assignments = remove_parent_code_assignments(code_assignments)
      prepare_pie_values_json(code_assignments)
    end

    def hssp2_strat_activities_pie(code_type, data_request_id, is_spent, activities = nil)
      column_name = get_hssp2_column_name(code_type)
      coding_type = get_hssp2_coding_type(is_spent)

      scope = CodeAssignment.scoped(
        :select => "codes.id as code_id,
                    codes.parent_id as parent_id,
                    codes.short_display,
                    codes.#{column_name} AS name,
                    SUM(code_assignments.cached_amount) AS value",
        :conditions => ["code_assignments.type = ?", coding_type],
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


      # when activities is not nil filter by activities
      if activities
        scope = scope.scoped(:conditions => ["activities.id IN (?)", activities.map(&:id)])
      end

      code_assignments = scope.all
      code_assignments = remove_parent_code_assignments(code_assignments)
      build_pie_values_json(get_summed_code_assignments(code_assignments))
    end
  end
end
