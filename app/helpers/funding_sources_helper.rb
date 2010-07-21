module FundingSourcesHelper

  def budget_column(record)
    number_to_currency(record.budget, :unit => "")
  end

end
