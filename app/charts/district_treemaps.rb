module DistrictTreemaps
  extend NumberHelper

  class << self
    def district_mtef_spent(location, activities)
      #return Code.treemap(location.activities, 'mtef_spend').to_json

      codes = Mtef.all + Nsp.all + Nha.all + Nasa.all
      roots = Mtef.roots
      type  = "CodingSpend"
      activity_value = "spend"

      get_treemap_rows(roots, codes, type, activities, location, activity_value).to_json
    end

    def district_mtef_budget(location, activities)
      #return Code.treemap(location.activities, 'mtef_budget').to_json
      codes = Mtef.all + Nsp.all + Nha.all + Nasa.all
      roots = Mtef.roots
      type  = "CodingBudget"
      activity_value = "budget"
      get_treemap_rows(roots, codes, type, activities, location, activity_value).to_json
    end

    def nsp_spent(location, activities)
      #return Code.treemap(location.activities, 'nsp_spend').to_json
      codes = Nsp.all
      roots = Nsp.roots
      type  = "CodingSpend"
      activity_value = "spend"
      get_treemap_rows(roots, codes, type, activities, location, activity_value).to_json
    end

    def nsp_budget(location, activities)
      #return Code.treemap(location.activities, 'nsp_budget').to_json
      codes = Nsp.all
      roots = Nsp.roots
      type  = "CodingBudget"
      activity_value = "budget"
      get_treemap_rows(roots, codes, type, activities, location, activity_value).to_json
    end


    private

      def get_treemap_rows(code_roots, codes, type, activities, location, activity_value)
        # format is my value, parent value, box_area_value, coloring_value
        activities = Activity.only_simple_activities(activities)

        rows = []
        root_sum = get_root_sum(code_roots.map(&:id), type, activities, location, activity_value)

        root_name = "#{n2c(root_sum)}: All Codes"
        rows << [root_name, nil, root_sum, 0]

        code_roots.each do |code|
          parent_display_cache = {} # code => display_value , used to connect rows
          parent_display_cache[code.parent_id] = root_name

          root_and_descendants = code.self_and_descendants
          treemap_sums = CodeAssignment.treemap_sums(root_and_descendants.map(&:id), type.to_s, activities)
          treemap_ratios = CodeAssignment.treemap_ratios(location.id, activities, activity_value)

          root_and_descendants.each do |c|
            sum = detect_sum(treemap_sums, treemap_ratios, c.id)
            get_treemap_row(c, rows, type, activities, parent_display_cache, root_sum, sum) if codes.include?(c)
          end
        end

        rows
      end

      def get_root_sum(code_ids, type, activities, location, activity_value)
        sum = 0

        code_ids.each do |code_id|
          treemap_sums = CodeAssignment.treemap_sums(code_id, type.to_s, activities)
          treemap_ratios = CodeAssignment.treemap_ratios(location.id, activities, activity_value)
          sum += detect_sum(treemap_sums, treemap_ratios, code_id)
        end

        sum
      end

      def get_treemap_row(code, rows, type, activities, treemap_parent_values, total_for_percentage, sum)
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

      def detect_sum(sums, ratios, code_id)
        sum = 0

        amounts = sums[code_id]
        if amounts.present?
          amounts.each do |amount|
            ratio = ratios[amount.activity_id]
            sum += amount.cached_amount * (ratio.present? ? ratio.first.ratio.to_f : 1)
          end
        end

        sum
      end
  end
end
