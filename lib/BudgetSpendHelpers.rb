module BudgetSpendHelpers

  def spend
    if total_quarterly_spending_w_shift
      total_quarterly_spending_w_shift
    else
      read_attribute(:spend)
    end
  end

  def total_quarterly_spending_w_shift
    if data_response
      if data_response.fiscal_year_start_date && data_response.fiscal_year_start_date.month == 10 # 7 is July
        total = 0
        [:spend_q4_prev, :spend_q1, :spend_q2, :spend_q3].each do |s|
          total += self.send(s) if self.send(s)
        end

        return total if total != 0
        nil
      else
        nil #"Fiscal Year shift not yet defined for this data responses' start date"
      end
    else
      nil
    end
  end

  def budget
    if total_quarterly_budget_w_shift
      total_quarterly_budget_w_shift
    else
      read_attribute(:budget)
    end
  end

  def total_quarterly_budget_w_shift
    if data_response
      if data_response.fiscal_year_start_date && data_response.fiscal_year_start_date.month == 10 # 7 is July
        total = 0
        [:budget_q4_prev, :budget_q1, :budget_q2, :budget_q3].each do |s|
          total += self.send(s) if self.respond_to?(s) and self.send(s)
        end

        return total if total != 0
        nil
      else
        nil #"Fiscal Year shift not yet defined for this data responses' start date"
      end
    else
      nil
    end
  end
  
  def toRWF
    toRWF = (Currency.find_by_symbol currency).try(:toRWF)
    if toRWF
      toRWF
    else
      0
    end
  end

  def spend_RWF
    toRWF = (Currency.find_by_symbol currency).try(:toRWF)
    if toRWF
      spend * toRWF
    else
      0
    end
  end

  def budget_RWF
    toRWF = (Currency.find_by_symbol currency).try(:toRWF)
    if toRWF
      budget * toRWF
    else
      0
    end
  end
end
