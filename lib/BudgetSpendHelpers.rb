module BudgetSpendHelpers
  GOR_QUARTERS = [:q1, :q2, :q3, :q4]

  def spend?
    !spend.nil? and spend > 0
  end

  def budget?
    !budget.nil? and budget > 0
  end

  def spend_RWF
    return 0 if spend.nil?
    spend * Money.default_bank.get_rate(currency, :RWF)
  end

  def budget_RWF
    return 0 if budget.nil?
    budget * Money.default_bank.get_rate(currency, :RWF)
  end

  # GN TODO: refactor for spend in quarters to total up
  # into spend field so only spend field is checked here
  def spend_entered?
    spend.present? || spend_q1.present? || spend_q2.present? ||
      spend_q3.present? || spend_q4.present? || spend_q4_prev.present?
  end

  def budget_entered?
    budget.present?
  end

  def total_by_type(amount_type)
    amounts = [
      self.send("#{amount_type}")
    ].compact.sum
  end

  def smart_sum(collection, method)
    s = collection.reject{|e| e.nil? or e.send(method).nil?}.sum{|e| e.send(method)}
    s || 0
  end

  def self.included(base)
    base.class_eval do
      validates_numericality_of :spend, :if => Proc.new {|model| model.spend.present?}
      validates_numericality_of :budget, :if => Proc.new {|model| model.budget.present?}

      if base.eql?(Activity) || base.eql?(FundingFlow)
        validates_numericality_of :spend_q4_prev, :if => Proc.new {|model| model.spend_q4_prev.present?}
        validates_numericality_of :spend_q1, :if => Proc.new {|model| model.spend_q1.present?}
        validates_numericality_of :spend_q2, :if => Proc.new {|model| model.spend_q2.present?}
        validates_numericality_of :spend_q3, :if => Proc.new {|model| model.spend_q3.present?}
        validates_numericality_of :spend_q4, :if => Proc.new {|model| model.spend_q4.present?}
        validates_numericality_of :budget_q4_prev, :if => Proc.new {|model| model.budget_q4_prev.present?}
        validates_numericality_of :budget_q1, :if => Proc.new {|model| model.budget_q1.present?}
        validates_numericality_of :budget_q2, :if => Proc.new {|model| model.budget_q2.present?}
        validates_numericality_of :budget_q3, :if => Proc.new {|model| model.budget_q3.present?}
        validates_numericality_of :budget_q4, :if => Proc.new {|model| model.budget_q4.present?}
      end

      if base.eql?(Project) || base.eql?(Activity)
        validates_numericality_of :budget2, :if => Proc.new{|model| model.budget2.present?}
        validates_numericality_of :budget3, :if => Proc.new{|model| model.budget3.present?}
        validates_numericality_of :budget4, :if => Proc.new{|model| model.budget4.present?}
        validates_numericality_of :budget5, :if => Proc.new{|model| model.budget5.present?}
      end
    end
  end

  protected

    # some older, unmigrated objects are going to break here...
    def check_data_response
      begin
        data_ok = self.data_response
      rescue RuntimeError => e
        # if the funding flow doesnt have a project, for example
        # then we cant do much!
        data_ok = nil
      end
      data_ok
    end
end
