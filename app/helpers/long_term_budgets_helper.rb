module LongTermBudgetsHelper
  def year_text_field_tag(budget_entries, field, year, index)
    budget_entry_year = year + index + 1
    entry  = budget_entries.detect{|be| be.year == budget_entry_year}
    amount = entry ? entry.amount : ''
    year_text_field_tag_with_name_and_amount("#{field}[#{index}]", amount)
  end

  def year_text_field_tag_with_name_and_amount(name, amount)
    text_field_tag(name, amount, :class => 'js_amount')
  end
end
