# This module is included in Activity, Project and FundingFlow models
module BudgetSpendHelper
  include NumberHelper

  def self.included(base)
    base.class_eval do

      ### Callbacks
      before_save :set_total_amounts
      if base.eql?(Activity) || base.eql?(FundingFlow)
        before_save :update_cached_usd_amounts
      end

      ### Validations
      validates_numericality_of :spend, :if => Proc.new {|model| model.spend.present?}
      validates_numericality_of :spend_q4_prev, :if => Proc.new {|model| model.spend_q4_prev.present?}
      validates_numericality_of :spend_q1, :if => Proc.new {|model| model.spend_q1.present?}
      validates_numericality_of :spend_q2, :if => Proc.new {|model| model.spend_q2.present?}
      validates_numericality_of :spend_q3, :if => Proc.new {|model| model.spend_q3.present?}
      validates_numericality_of :spend_q4, :if => Proc.new {|model| model.spend_q4.present?}
      validates_numericality_of :budget, :if => Proc.new {|model| model.budget.present?}
      validates_numericality_of :budget_q4_prev, :if => Proc.new {|model| model.budget_q4_prev.present?}
      validates_numericality_of :budget_q1, :if => Proc.new {|model| model.budget_q1.present?}
      validates_numericality_of :budget_q2, :if => Proc.new {|model| model.budget_q2.present?}
      validates_numericality_of :budget_q3, :if => Proc.new {|model| model.budget_q3.present?}
      validates_numericality_of :budget_q4, :if => Proc.new {|model| model.budget_q4.present?}

      if base.eql?(Project) || base.eql?(Activity)
        validates_numericality_of :budget2, :if => Proc.new{|model| model.budget2.present?}
        validates_numericality_of :budget3, :if => Proc.new{|model| model.budget3.present?}
        validates_numericality_of :budget4, :if => Proc.new{|model| model.budget4.present?}
        validates_numericality_of :budget5, :if => Proc.new{|model| model.budget5.present?}
      end

    end
  end

  def spend?
    !spend.nil? and spend > 0
  end

  def budget?
    !budget.nil? and budget > 0
  end

  def spend_entered?
    spend.present? || spend_q1.present? || spend_q2.present? ||
      spend_q3.present? || spend_q4.present? || spend_q4_prev.present?
  end

  def budget_entered?
    budget.present? || budget_q1.present? || budget_q2.present? ||
      budget_q3.present? || budget_q4.present? || budget_q4_prev.present?
  end

  def smart_sum(collection, method)
    s = collection.reject{|e| e.nil? or e.send(method).nil?}.sum{|e| e.send(method)}
    s || 0
  end

  private
    def total_amount_of_quarters(type)
      (self.send("#{type}_q1") || 0) +
      (self.send("#{type}_q2") || 0) +
      (self.send("#{type}_q3") || 0) +
      (self.send("#{type}_q4") || 0)
    end

    # set the total amount if the quarters are set
    def set_total_amounts
      ["budget", "spend"].each do |type|
        amount = total_amount_of_quarters(type)
        self.send(:"#{type}=", amount) if amount && amount > 0
      end
    end

    def update_cached_usd_amounts
      rate = currency_rate(self.currency, :USD)
      self.budget_in_usd = (gor_budget || 0) * rate
      self.spend_in_usd  = (gor_spend || 0)  * rate
    end
end
