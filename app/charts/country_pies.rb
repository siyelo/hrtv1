module Charts::CountryPies
  extend Charts::HelperMethods

  class << self
    ### admin/district/:id/organizations
    def organizations_pie(code_type)
      records = Organization.find :all,
        :select => "organizations.id,
                    organizations.name as my_name,
                    SUM(ca1.cached_amount_in_usd/100) as value",
      :joins => "INNER JOIN data_responses dr1 ON organizations.id = dr1.organization_id_responder
        INNER JOIN activities a1 ON dr1.id = a1.data_response_id
        INNER JOIN code_assignments ca1 ON a1.id = ca1.activity_id
          AND ca1.type = '#{code_type}'",
      :group => "organizations.id,
                 organizations.name",
      :order => "value DESC"

      prepare_pie_values(records)
    end

    def activities_pie(coding_type)
      code_assignments = CodeAssignment.with_type(coding_type).find(:all,
        :select => "code_assignments.id,
                    code_assignments.activity_id,
                    COALESCE(activities.name, activities.description) AS my_name,
                    SUM(code_assignments.cached_amount_in_usd/100) AS value",
        :joins => :activity,
        :include => :activity,
        :group => 'code_assignments.id,
                   code_assignments.activity_id,
                   my_name',
        :order => 'value DESC')

      prepare_pie_values(code_assignments)
    end

    def codes_for_country_pie(code_type, is_spent)
      codes = get_codes(code_type)
      coding_type = get_coding_type(code_type, is_spent)

      code_assignments = CodeAssignment.with_type(coding_type).with_code_ids(codes).find(:all,
              :select => "code_assignments.code_id,
                codes.short_display as my_name,
                SUM(code_assignments.cached_amount_in_usd/100) AS value",
              :joins => :code,
              :group => 'code_assignments.code_id,
                         codes.short_display',
              :order => 'value DESC')

      prepare_pie_values(code_assignments)
    end

    def codes_for_activities_pie(code_type, activities, is_spent)
      code_klass_string = get_code_klass_string(code_type)
      coding_type       = get_coding_type(code_type, is_spent)

      code_assignments = CodeAssignment.find(:all,
        :select => "codes.id as code_id,
                    codes.parent_id as parent_id,
                    codes.short_display AS my_name,
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

      prepare_pie_values(code_assignments)
    end

    private

      def prepare_pie_values(code_assignments)
        values = []
        other = 0.0

        code_assignments.each_with_index do |ca, index|
          if index < 10
            values << [ca.my_name, ca.value.to_f.round(2)]
          else
            other += ca.value.to_f
          end
        end

        values << ['Other', other.round(2)]

        {
          :values => values,
          :names => {:column1 => 'Name', :column2 => 'Amount'}
        }.to_json
      end
  end
end
