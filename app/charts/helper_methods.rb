module HelperMethods
  MTEF_CODE_LEVEL = 1 # all level 1 MTEF codes

  def get_coding_type(code_type, is_spent)
    case code_type
    when 'nsp', 'mtef'
      is_spent ? "CodingSpend" : "CodingBudget"
    when 'cost_category'
      is_spent ? "CodingSpendCostCategorization" : "CodingBudgetCostCategorization"
    end
  end

  def get_code_klass_string(code_type)
    case code_type
    when 'nsp'
      'Nsp'
    when 'mtef'
      'Mtef'
    when 'cost_category'
      'CostCategory'
    else
      raise "Invalid code type #{code_type}".to_yaml
    end
  end

  def get_code_klass(code_type)
    case code_type
    when 'nsp'
      Nsp
    when 'mtef'
      Mtef
    when 'cost_category'
      CostCategory
    else
      raise "Invalid code type #{code_type}".to_yaml
    end
  end

  def get_codes(code_type)
    case code_type
    when 'nsp'
      Nsp.roots
    when "mtef"
      Mtef.codes_by_level(MTEF_CODE_LEVEL)
    when 'cost_category'
      CostCategory.roots
    else
      raise "Invalid code type #{code_type}".to_yaml
    end
  end

  def get_all_code_ids(root_codes)
    root_codes.inject([]){|code_ids, code| code_ids.concat(code.self_and_descendants.map(&:id))}.uniq
  end

  def get_root_codes_sum(root_codes, sums)
    #raise root_codes.to_yaml
    #raise root_codes.map(&:id).to_yaml
    root_codes.inject(0){|sum, code| sum + sums[code.id]}
  end

  def get_code_assignments_for_codes_pie(code_klass_string, coding_type, activities)
    code_assignments = CodeAssignment.find(:all,
      :select => "codes.id as code_id,
                  codes.parent_id as parent_id,
                  codes.short_display AS my_name,
                  SUM(code_assignments.new_cached_amount_in_usd / 100) AS value",
      :conditions => ["codes.type = ?
        AND code_assignments.type = ?
        AND activities.id IN (?)",
        code_klass_string, coding_type, activities.map(&:id)],
      :joins => [:activity, :code],
      :group => "codes.short_display, codes.id, codes.parent_id",
      :order => 'value DESC')

    remove_parent_code_assignments(code_assignments)
  end

  def remove_parent_code_assignments(code_assignments)
    parent_ids = code_assignments.collect{|n| n.parent_id} - [nil]
    parent_ids.uniq!

    # remove cached (parent) code assignments
    code_assignments = code_assignments.reject{|ca| parent_ids.include?(ca.code_id)}
  end

end
