module Activity::GorAmountHelpers

  # NOTE: organizations reporting in GOR FY
  # are entering q1, q2, q3, and q4, but
  # organizations reporting in USG FY
  # are entering q4_prev, q1, q2, q3, and q4
  # because in the reports we need the following mapping:
  # USG :q4_prev = GOR q1
  # USG :q1      = GOR q2
  # USG :q2      = GOR q3
  # USG :q3      = GOR q4
  GOR_QUARTERS = [:q1, :q2, :q3, :q4]
  USG_QUARTERS = [:q4_prev, :q1, :q2, :q3]
  USG_START_MONTH = 10

  class InvalidQuarter < StandardError; end

  def gor_budget_quarter(quarter)
    get_gor_quarter(:budget, quarter)
  end

  def gor_spend_quarter(quarter)
    get_gor_quarter(:spend, quarter)
  end

  def gor_spend
    total_quarterly_w_shift(:spend)
  end

  def gor_budget
    total_quarterly_w_shift(:budget)
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

  private

    def get_gor_quarter(method, quarter)
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
