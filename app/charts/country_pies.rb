module Charts::CountryPies
  extend Charts::HelperMethods

  class << self
    ### admin/district/:id/organizations
    def organizations_pie(code_type)
      records = Organization.find :all,
        :select => "organizations.id,
                    organizations.name as name,
                    SUM(ca1.cached_amount_in_usd) as value",
      :joins => "INNER JOIN data_responses dr1 ON organizations.id = dr1.organization_id
        INNER JOIN activities a1 ON dr1.id = a1.data_response_id
        INNER JOIN code_assignments ca1 ON a1.id = ca1.activity_id
          AND ca1.type = '#{code_type}'",
      :group => "organizations.id,
                 organizations.name",
      :order => "value DESC"

      prepare_pie_values_json(records)
    end

    def ultimate_funding_sources(amount_type)
      records = FundingStream.find :all,
        :select => "organizations.id,
          organizations.name,
          SUM(funding_streams.#{amount_type}) as value",
        :joins => "INNER JOIN organizations ON
                    funding_streams.organization_ufs_id = organizations.id",
        :group => "organizations.id,
                   organizations.name",
        :order => "value DESC"

      prepare_pie_values_json(records)
    end

    def financing_agents(amount_type)
      records = FundingStream.find :all,
        :select => "organizations.id,
          organizations.name,
          SUM(funding_streams.#{amount_type}) as value",
        :joins => "INNER JOIN organizations ON
                    funding_streams.organization_fa_id = organizations.id",
        :group => "organizations.id,
                   organizations.name",
        :order => "value DESC"

      prepare_pie_values_json(records)
    end

    def implementers(amount_type)
      records = FundingStream.find :all,
        :select => "organizations.id,
          organizations.name,
          SUM(funding_streams.#{amount_type}) as value",
        :joins => "INNER JOIN projects ON projects.id = funding_streams.project_id
                   INNER JOIN activities ON activities.project_id = projects.id
                   INNER JOIN organizations ON activities.provider_id = organizations.id",
        :group => "organizations.id,
                   organizations.name",
        :order => "value DESC"

      prepare_pie_values_json(records)
    end

    def activities_pie(coding_type)
      code_assignments = CodeAssignment.with_type(coding_type).find(:all,
        :select => "code_assignments.id,
                    code_assignments.activity_id,
                    COALESCE(activities.name, activities.description) AS name_or_descr,
                    SUM(code_assignments.cached_amount_in_usd) AS value",
        :joins => :activity,
        :include => :activity,
        :group => 'code_assignments.id,
                   code_assignments.activity_id,
                   name_or_descr',
        :order => 'value DESC')

      prepare_pie_values_json(code_assignments)
    end

    def codes_for_country_pie(code_type, is_spent)
      codes = get_codes(code_type)
      coding_type = get_coding_type(code_type, is_spent)

      code_assignments = CodeAssignment.with_type(coding_type).with_code_ids(codes).find(:all,
              :select => "code_assignments.code_id,
                codes.short_display as name,
                SUM(code_assignments.cached_amount_in_usd) AS value",
              :joins => :code,
              :group => 'code_assignments.code_id,
                         codes.short_display',
              :order => 'value DESC')

      prepare_pie_values_json(code_assignments)
    end

    def codes_for_activities_pie(code_type, activities, is_spent)
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
        :joins => [:activity, :code],
        :group => "codes.short_display, codes.id, codes.parent_id",
        :order => 'value DESC')

      parent_ids = code_assignments.collect{|n| n.parent_id} - [nil]
      parent_ids.uniq!

      # remove cached (parent) code assignments
      code_assignments = code_assignments.reject{|ca| parent_ids.include?(ca.code_id)}

      prepare_pie_values_json(code_assignments)
    end
  end
end
