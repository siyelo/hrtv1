module Charts::ActivityTreemaps
  extend NumberHelper

  class << self
    def activity_treemap(activity, chart_type)
      case chart_type
      when 'budget_coding'
        coding_treemap(activity, CodingBudget, activity.budget)
      when 'budget_districts'
        districts_treemap(activity.coding_budget_district, activity.budget)
      when 'budget_cost_categorization'
        coding_treemap(activity, CodingBudgetCostCategorization, activity.budget)
      when 'spend_coding'
        coding_treemap(activity, CodingSpend, activity.spend)
      when 'spend_districts'
        districts_treemap(activity.coding_spend_district, activity.spend)
      when 'spend_cost_categorization'
        coding_treemap(activity, CodingSpendCostCategorization, activity.spend)
      else
        raise "Wrong chart type".to_yaml
      end
    end

    def activities_treemap(activities, chart_type)
      case chart_type
      when 'mtef_budget'
        codes = Mtef.all + Nsp.all + Nha.all + Nasa.all
        roots = Mtef.roots
        type  = "CodingBudget"
      when 'mtef_spend'
        codes = Mtef.all + Nsp.all + Nha.all + Nasa.all
        roots = Mtef.roots
        type  = "CodingSpend"
      when 'nsp_budget'
        codes = Nsp.all
        roots = Nsp.roots
        type  = "CodingBudget"
      when 'nsp_spend'
        codes = Nsp.all
        roots = Nsp.roots
        type  = "CodingSpend"
      when 'cc_budget'
        codes = CostCategory.all
        roots = CostCategory.roots
        type  = "CodingBudgetCostCategorization"
      when 'cc_spend'
        codes = CostCategory.all
        roots = CostCategory.roots
        type  = "CodingSpendCostCategorization"
      else
        raise "Wrong chart type".to_yaml
      end

      data_rows = get_treemap_rows(roots, codes, type, activities)
    end

    private

      def coding_treemap(activity, type, total_amount)
        coding_tree = CodingTree.new(activity, type)
        root_codes  = coding_tree.root_codes
        assignments = type.with_activity(activity).all.map_to_hash{ |b| {b.code_id => b} }

        data_rows = []
        treemap_root = "#{n2c(get_sum(root_codes, assignments))}: All Codes"
        data_rows << [treemap_root, nil, 0, 0] #TODO amount

        root_codes.each do |code|
          build_treemap_rows(data_rows, code, treemap_root, total_amount, assignments)
        end
        return data_rows
      end

      def districts_treemap(code_assignments, total_amount)
        data_rows = []
        treemap_root = "#{n2c(code_assignments.inject(0){|sum, d| sum + d.cached_amount})}: All Codes"
        data_rows << [treemap_root, nil, 0, 0]
        code_assignments.each do |assignment|
          percentage  = total_amount ? (assignment.cached_amount / total_amount * 100).round(0) : "?"
          label       = "#{percentage}%: #{assignment.code.to_s_prefer_official}"
          data_rows << [label, treemap_root, assignment.cached_amount, assignment.cached_amount]
        end
        data_rows
      end

      def build_treemap_rows(data_rows, code, parent_name, total_amount, assignments)
        if assignments.has_key?(code.id)
          percentage  = total_amount ? (assignments[code.id].cached_amount.to_f / total_amount * 100).round(0) : "?"
          label       = "#{percentage}%: #{code.to_s_prefer_official}"
          data_rows << [label, parent_name, assignments[code.id].cached_amount, assignments[code.id].cached_amount]
          unless code.leaf?
            code.children.each do |child|
              build_treemap_rows(data_rows, child, label, total_amount, assignments)
            end
          end
        end
      end

      def get_sum(root_codes, assignments)
        sum = 0
        root_codes.each do |code|
          sum += assignments[code.id].cached_amount if assignments.has_key?(code.id)
        end
        sum
      end

      def get_treemap_rows(root_codes, codes, type, activities)
        # format is my value, parent value, box_area_value, coloring_value
        activities = Activity.only_simple_activities(activities)
        rows = []
        sum_of_roots = 0
        root_codes.each do |r|
          s = r.sum_of_assignments_for_activities(type, activities)
          #logger.debug("#{r.to_s} - sum is #{s.to_s}")
          sum_of_roots += s
        end
        root_name = "#{n2c(sum_of_roots)}: All Codes"
        rows << [root_name, nil, sum_of_roots, 0]
        #return rows
        root_codes.each do |r|
          parent_display_cache = {} # code => display_value , used to connect rows
          parent_display_cache[r.parent] = root_name
          Code.each_with_level(r.self_and_descendants) do |c,level|
            get_treemap_row(c, rows, type, activities, parent_display_cache, level, sum_of_roots) if codes.include?(c)
          end
        end

        rows
      end

      def get_treemap_row(code, rows, type, activities, treemap_parent_values, level, total_for_percentage)
        name  = code.to_s_prefer_official
        sum   = code.sum_of_assignments_for_activities(type, activities)
        ignore_second_parent = treemap_parent_values.empty? || treemap_parent_values.keys.include?(code.parent_id) # TODO: data problem with treemap: uncaught exception: Parent doubly defined.

        if sum > 0 && ignore_second_parent #TODO add % of total as well, abbrev amount
          name_w_sum = "#{n2c(sum.fdiv(total_for_percentage)*100)}%: #{name}"
          if treemap_parent_values.values.include?(name_w_sum)
            name_w_sum = "#{n2c(sum)} (2): #{name}"
          end
          treemap_parent_values[code] = name_w_sum

          my_parent_treemap_value = treemap_parent_values[code.parent]
          rows << [name_w_sum, my_parent_treemap_value, sum, sum]
        end
      end
  end
end
