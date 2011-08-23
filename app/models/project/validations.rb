module Project::Validations

  def validation_errors
    errors = []
    errors
  end

  def linked?
    in_flows.all?{ |in_flow| in_flow.project_from_id }
  end

  def matches_in_flow_amount?(amount_method)
    send(amount_method) == in_flows_total(amount_method)
  end
end
