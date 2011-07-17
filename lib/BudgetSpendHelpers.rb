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
  #def spend
    #amount = total_quarterly_w_shift(:spend)
    #amount ? amount : read_attribute(:spend)
  #end

  #def budget
    #amount = total_quarterly_w_shift(:budget)
    #amount ? amount : read_attribute(:budget)
  #end

  def budget_quarter(quarter)
    get_quarter(:budget, quarter)
  end

  def spend_quarter(quarter)
    get_quarter(:spend, quarter)
  end

  def total_quarterly_w_shift(amount_type)
    total = 0
    if data_response.fiscal_year_start_date &&
       data_response.fiscal_year_start_date.month == USG_START_MONTH
      quarted_lookup = USG_QUARTERS
    else
      quarted_lookup = GOR_QUARTERS
    end

    quarted_lookup.each do |quarter|
      amount = self.send(:"#{amount_type}_#{quarter}")
      total += amount if amount
    end

    return total if total != 0
    nil
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
    total_quarterly_w_shift(type)
    #(self.send("#{type}_q4_prev") || 0) +
    #(self.send("#{type}_q1") || 0) +
    #(self.send("#{type}_q2") || 0) +
    #(self.send("#{type}_q3") || 0)
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
