module LongTermBudgetsHelper
  def year_text_field_tag(budget_entries, field, year, index)
    budget_entry_year = year + index + 1
    entry  = budget_entries.detect{|be| be.year == budget_entry_year}
    amount = entry ? entry.amount : ''
    text_field_tag("#{field}[#{index}]", amount, :class => 'js_year')
  end
end
