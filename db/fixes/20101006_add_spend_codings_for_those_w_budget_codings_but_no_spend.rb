to_move_to_if_missing = { CodingBudget => CodingSpend,
  CodingBudgetCostCategorization => CodingSpendCostCategorization,
  CodingBudgetDistrict => CodingSpendDistrict}

Activity.all.each do |a|
  unless a.class == SubActivity
    to_move_to_if_missing.each do |from, to|
      coding = from.with_activity(a)
      to_coding = to.with_activity(a)
      if to_coding.empty?

      end
    end
  end
end

# now save sub activity codings, which will take their parent's
# expenditure codings made from the above, if they have a spend

