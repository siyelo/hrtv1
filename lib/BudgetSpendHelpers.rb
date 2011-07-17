module BudgetSpendHelpers

  USG_QUARTERS = [:q4_prev, :q1, :q2, :q3]
  GOR_QUARTERS = [:q1, :q2, :q3, :q4]
  USG_START_MONTH = 10 # 7 is July

  class InvalidQuarter < StandardError; end

  def spend?
    !spend.nil? and spend > 0
  end

  def budget?
    !budget.nil? and budget > 0
  end

  # add spend_gor_qX methods here
  def spend
    if total_quarterly_spending_w_shift
      total_quarterly_spending_w_shift
    else
      read_attribute(:spend)
    end
  end

  def total_quarterly_spending_w_shift
    if data_response.fiscal_year_start_date &&
       data_response.fiscal_year_start_date.month == USG_START_MONTH
      total = 0
      [:spend_q4_prev, :spend_q1, :spend_q2, :spend_q3].each do |s|
        total += self.send(s) if self.send(s)
      end

      return total if total != 0
      nil
    else
      nil #"Fiscal Year shift not yet defined for this data responses' start date"
    end
  end

  def budget
    if total_quarterly_budget_w_shift
      total_quarterly_budget_w_shift
    else
      read_attribute(:budget)
    end
  end

  def budget_quarter(quarter)
    get_quarter(:budget, quarter)
  end

  def spend_quarter(quarter)
    get_quarter(:spend, quarter)
  end

  def total_quarterly_budget_w_shift
    if data_response.fiscal_year_start_date &&
       data_response.fiscal_year_start_date.month == USG_START_MONTH
      total = 0
      [:budget_q4_prev, :budget_q1, :budget_q2, :budget_q3].each do |s|
        total += self.send(s) if self.respond_to?(s) and self.send(s)
      end

      return total if total != 0
      nil
    else
      nil #"Fiscal Year shift not yet defined for this data responses' start date"
    end
  end

  # GN TODO: refactor for spend in quarters to total up
  # into spend field so only spend field is checked here
  def spend_entered?
    spend.present? || spend_q1.present? || spend_q2.present? ||
      spend_q3.present? || spend_q4.present? || spend_q4_prev.present?
  end

  def budget_entered?
    budget.present? || budget_q1.present? || budget_q2.present? ||
      budget_q3.present? || budget_q4.present? || budget_q4_prev.present?
  end

  def smart_sum(collection, method)
    s = collection.reject{|e| e.nil? or e.send(method).nil?}.sum{|e| e.send(method)}
    s || 0
  end

  def total_amount_of_quarters(type)
    (self.send("#{type}_q4_prev") || 0) +
    (self.send("#{type}_q1") || 0) +
    (self.send("#{type}_q2") || 0) +
    (self.send("#{type}_q3") || 0)
  end

  protected
    def get_quarter(method, quarter)
      raise InvalidQuarter unless [1, 2, 3, 4].include?(quarter)

      if data_response.fiscal_year_start_date &&
          data_response.fiscal_year_start_date.month == USG_START_MONTH
        quarted_lookup = USG_QUARTERS
      else
        quarted_lookup = GOR_QUARTERS
      end

      self.send(:"#{method}_#{quarted_lookup[quarter-1]}")
    end
end
