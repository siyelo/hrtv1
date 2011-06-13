Activity.find(:all).each do |activity|
  if activity.use_budget_codings_for_spend
    puts "Copying budget codings to past expenditure codings for activity #{activity.id}"
    activity.copy_budget_codings_to_spend
  end
end
