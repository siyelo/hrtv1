module Project::Validations

  def validation_errors
    errors = []

    errors << "Project Past Expenditure Total (#{n2cnd(spend, currency)}) does not match the Funding Source Past Expenditure Total (#{n2cnd(in_flows_total(:spend), currency)}). Please update Past Expenditures accordingly." unless matches_in_flow_amount?(:spend)

    errors << "Project Current Budget Total (#{n2cnd(budget, currency)}) does not match the Funding Source Current Budget Total (#{n2cnd(in_flows_total(:budget), currency)}). Please update Current Budgets accordingly." unless matches_in_flow_amount?(:budget)

    errors << "Project is not currently linked." unless linked?

    errors
  end

  def linked?
    in_flows.all?{ |in_flow| in_flow.project_from_id }
  end

  def matches_in_flow_amount?(amount_method)
    send(amount_method) == in_flows_total(amount_method)
  end
end
