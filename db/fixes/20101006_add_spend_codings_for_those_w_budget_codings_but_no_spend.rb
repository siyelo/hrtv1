
# use past expenditure codings for budget if they are missing
to_move_to_if_missing = { CodingBudget => CodingSpend,
  CodingBudgetCostCategorization => CodingSpendCostCategorization,
  CodingBudgetDistrict => CodingSpendDistrict}

Activity.all.each do |a|
  unless a.class == SubActivity
    to_move_to_if_missing.each do |from, to|
      coding = from.with_activity(a)
      to_coding = to.with_activity(a)
      if to_coding.empty? && a.spend && a.spend > 0 && !a.budget.nil? && a.budget > 0
        CodeAssignment.copy_coding_from_budget_to_spend coding, to
      end
    end
  end
end

# now save sub activity codings, which will take their parent's
# expenditure codings made from the above, if they have a past expenditure
# and budget ones as well

Activity.all.each do |a|
    to_move_to_if_missing.each do |from, to| #reuse since it has all the coding classes in it
      coding = from.with_activity(a)
      to_coding = to.with_activity(a)
      [coding, to_coding].each do |coding|
        coding.each do |ca|
          puts "error on activity #{a.id} for #{ca.code_id} #{ca.class}" unless ca.save
        end
      end
  end
end

# now, save the hssp2 code_assignments

Activity.all.each do |a|
  [:budget_stratprog_coding,:spend_stratprog_coding,
    :budget_stratobj_coding,:spend_stratobj_coding].each do |coding|
    coding = a.send(coding)
    coding.each do |ca|
      puts "error on activity #{a.id} for #{ca.code_id} #{ca.class}" unless ca.save
    end
  end
end
