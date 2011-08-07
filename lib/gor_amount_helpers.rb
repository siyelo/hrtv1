module GorAmountHelpers

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
    organization.usg? ? usg_to_gor_quarters_total(:spend) : (spend || 0)
  end

  def gor_budget
    organization.usg? ? usg_to_gor_quarters_total(:budget) : (budget || 0)
  end

  private
    def get_gor_quarter(method, quarter)
      raise InvalidQuarter unless [1, 2, 3, 4].include?(quarter)

      quarted_lookup = organization.usg? ? USG_QUARTERS : GOR_QUARTERS
      self.send(:"#{method}_#{quarted_lookup[quarter-1]}")
    end

    def usg_to_gor_quarters_total(amount_type)
      USG_QUARTERS.inject(0){|acc, q| acc + (self.send("#{amount_type}_#{q}") || 0)}
    end
end
