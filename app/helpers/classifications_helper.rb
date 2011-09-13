module ClassificationsHelper
  def all_view?
    params[:view] != 'my'
  end

  def code_classified?(budget_assignments, spend_assignments, code)
    budget_assignments.has_key?(code.id) || spend_assignments.has_key?(code.id)
  end

  def derive_percentage_from_amount(activity_or_ocost, amount_field, assignment)
    if assignment
      if assignment.percentage.nil?
        percentage = activity_or_ocost.send(amount_field) > 0 ? (100 / (activity_or_ocost.send(amount_field).to_f / assignment.cached_amount.to_f)).to_f.round_with_precision(2).to_s : 0
      else
        percentage = assignment.percentage.to_f.round_with_precision(2)
      end
    else
      percentage = ''
    end
  end
end
