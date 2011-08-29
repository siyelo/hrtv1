# Activity.only_simple.each do |a|
#   sab_total = a.sub_activities.reject{|sa| sa.budget.nil?}.sum(&:budget)
#   sae_total = a.sub_activities.reject{|sa| sa.spend.nil?}.sum(&:spend)
#   spends_match = (a.spend == sae_total)
#   budgets_match =  (sab_total == a.budget)
#   puts "#{a.organization_name}: (#{a.data_response_id})/(#{a.id}): #{a.name.first(20)}: spend: #{a.spend}   -   #{sae_total} =  #{(a.spend - sae_total)}" if !spends_match && sae_total > 0 && a.spend.to_i > 0
#   puts "#{a.organization_name}: (#{a.data_response_id})/(#{a.id}): #{a.name.first(20)}: budget: #{a.budget}  -   #{sab_total} =  #{(a.budget - sab_total)}" if !budgets_match && sab_total > 0 && a.budget.to_i > 0
# end

Organization.ordered.each do |org|
  org.data_responses.each do |dr|
    dr.activities.only_simple.each do |a|
      unless a.implementer_splits.empty?
        sab_total = a.implementer_splits.reject{|sa| sa.budget.nil?}.sum(&:budget)
        sae_total = a.implementer_splits.reject{|sa| sa.spend.nil?}.sum(&:spend)
        spends_match = (a.spend.to_f == sae_total)
        budgets_match =  (sab_total == a.budget.to_f)
        unless spends_match && budgets_match
          puts "#{a.organization_name} (#{org.id})"
          puts "  #{a.name.first(20)}... (#{a.data_response_id})/(#{a.id})"
          puts ""
          provider = (a.provider.try(:name)) || ""
          provider = "<SELF>" if a.provider == org
          puts "    #{( provider + (" " * 20)).first(20)} (#{a.provider_id})"
          puts ""
          a.implementer_splits.each do |is|
            puts "    #{( (is.implementer_name || "") + (" " * 20)).first(20)},           #{is.spend.to_s},        #{is.budget.to_s}"
          end
          puts "    "
          puts "      SI TOTAL:                         #{sae_total},        #{sab_total}"
          puts ""
          puts "      ACTIVITY TOTAL:                   #{a.spend},        #{a.budget}"
          puts ""
          puts "      DIFF:                             #{a.spend.to_f - sae_total},        #{a.budget.to_f - sab_total}"
          puts "\n\n"
        end
      end
    end
  end
end