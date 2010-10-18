module SpendBudgetInRWF
  def spend_RWF
    toRWF = (Currency.find_by_symbol currency).try(:toRWF)
    if toRWF
      spend * toRWF
    else
      0
    end
  end

  def budget_RWF
    toRWF = (Currency.find_by_symbol currency).try(:toRWF)
    if toRWF
      budget * toRWF
    else
      0
    end
  end
end
