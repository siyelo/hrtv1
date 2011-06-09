module WorkplansHelper
  def format_budget_date (date, i = 0)
    "#{date.strftime('%b')}'#{date.strftime('%y').to_i + i}"
  end
end
