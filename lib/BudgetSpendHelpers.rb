module BudgetSpendHelpers

  def spend
    if total_quarterly_spending_w_shift
      total_quarterly_spending_w_shift
    else
      read_attribute(:spend)
    end
  end

  def total_quarterly_spending_w_shift
    if check_data_response()
      if data_response.fiscal_year_start_date &&
         data_response.fiscal_year_start_date.month == 10 # 7 is July
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
    if check_data_response()
      if data_response.fiscal_year_start_date &&
         data_response.fiscal_year_start_date.month == 10 # 7 is July
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
    toRWF = Currency.find_by_symbol(currency).try(:toRWF)
    toRWF ? toRWF : 0
  end

  def spend_RWF
    return 0 if spend.nil?
    toRWF = Currency.find_by_symbol(currency).try(:toRWF)
    toRWF ? spend * toRWF : 0
  end

  def budget_RWF
    return 0 if budget.nil?
    toRWF = Currency.find_by_symbol(currency).try(:toRWF)
    toRWF ? budget * toRWF : 0
  end

protected

  # some older, unmigrated objects are going to break here...
  def check_data_response
    begin
      data_ok = self.data_response
    rescue RuntimeError => e
      # if the funding flow doesnt have a project, for example
      # then we cant do much!
      data_ok = nil
    end
    data_ok
  end
end
