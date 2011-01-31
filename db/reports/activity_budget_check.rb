

total_budget = 0
total_spend  = 0
total_budget_usd = 0
total_spend_usd  = 0

d.activities.each do |a|
  total_spend += a.spend || 0
  total_budget += a.budget || 0
  total_spend_usd += a.spend_in_usd ||0
  total_budget_usd += a.budget_in_usd||0
  a.code_assignments.each do |ca|
    puts "#{a.id},
          #{a.currency},
          #{a.budget.to_s},
          $#{a.budget_in_usd.round(2)},
          #{a.spend.to_s},
          $#{(a.spend_in_usd.round(2))},
          #{ca.id},
          #{ca.type},
          #{ca.cached_amount},
          $#{ca.cached_amount_in_usd.round(2)},
          #{a.CodingBudget_amount},
          #{a.CodingBudgetDistrict_amount},
          #{a.CodingBudgetCostCategorization_amount},
          #{a.CodingSpend_amount},
          #{a.CodingSpendDistrict_amount},
          #{a.CodingSpendCostCategorization_amount}"
    end
end

puts "Total Budget: #{total_budget},
      Total Spend: #{total_spend},
      Total Budget USD: #{total_budget_usd},
      Total Spend USD: #{total_spend_usd}"