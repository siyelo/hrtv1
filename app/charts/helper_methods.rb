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

  def get_code_klass(code_type)
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
end
