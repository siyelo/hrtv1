module Charts
  module CountryTreemaps
    extend NumberHelper
    extend Charts::HelperMethods

    class << self
      def treemap(code_type, activities, is_spent)
        case code_type
        when 'mtef'
          codes   = Mtef.all + Nsp.all + Nha.all + Nasa.all
          roots   = Mtef.roots
        when 'nsp'
          codes   = Nsp.all
          roots   = Nsp.roots
        when 'cost_category'
          codes = CostCategory.all
          roots = CostCategory.roots
        else
          raise "Invalid type for district treemap".to_yaml
        end

        coding_type = get_coding_type(code_type, is_spent)

        get_treemap_rows(roots, codes, coding_type, activities).to_json
      end

      private

        def get_treemap_rows(root_codes, codes, coding_type, activities)
          code_ids           = get_all_code_ids(root_codes)

          scope = CodeAssignment.with_code_ids(code_ids).with_type(coding_type)

          scope = scope.with_activities(activities) if activities && activities.kind_of?(Array)

          # format is my value, parent value, box_area_value, coloring_value
          code_assignments   = scope.find(:all,
            :select => 'code_assignments.code_id, code_assignments.activity_id, SUM(code_assignments.cached_amount_in_usd) AS value',
            :group => 'code_assignments.code_id, code_assignments.activity_id',
            :order => 'value DESC'
          ).group_by{|ca| ca.code_id}
          treemap_sums       = prepare_treemap_sums(code_assignments, code_ids)

          rows           = []

          root_codes_sum = get_root_codes_sum(root_codes, treemap_sums)
          root_name = "#{n2c(root_codes_sum)}: All Codes"

          rows << [root_name, nil, root_codes_sum, 0]

          root_codes.each do |code|
            parent_display_cache = {} # code => display_value , used to connect rows
            parent_display_cache[code.parent_id] = root_name

            code.self_and_descendants.each do |c|
              sum = treemap_sums[c.id]
              get_treemap_row(c, rows, parent_display_cache, root_codes_sum, sum) if codes.include?(c)
            end
          end

          rows
        end

        def get_treemap_row(code, rows, treemap_parent_values, total_for_percentage, sum)
          name  = code.to_s_prefer_official

          ignore_second_parent = treemap_parent_values.empty? || treemap_parent_values.keys.include?(code.parent_id) # TODO: data problem with treemap: uncaught exception: Parent doubly defined.

          if sum > 0 && ignore_second_parent
            name_w_sum = "#{n2c(sum.fdiv(total_for_percentage)*100)}%: #{name}"
            if treemap_parent_values.values.include?(name_w_sum)
              name_w_sum = "#{n2c(sum)} (2): #{name}"
            end
            treemap_parent_values[code.id] = name_w_sum
            my_parent_treemap_value = treemap_parent_values[code.parent_id]
            rows << [name_w_sum, my_parent_treemap_value, sum, sum]
          end
        end

        def prepare_treemap_sums(code_assignments, code_ids)
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
end
