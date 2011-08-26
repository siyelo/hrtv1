# This module is included in Activity, Project and FundingFlow models
module BudgetSpendHelper
  include NumberHelper

  def self.included(base)
    base.class_eval do

      ### Callbacks
      if base.eql?(FundingFlow)
        before_save :update_cached_usd_amounts
      end

      if base.eql?(Activity)
        before_save :update_cached_usd_amounts
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
    spend.present?
  end

  def budget_entered?
    budget.present?
  end

  def smart_sum(collection, method)
    s = collection.reject{|e| e.nil? or e.send(method).nil?}.sum{|e| e.send(method)}
    s || 0
  end

  private

    def update_cached_usd_amounts
      rate = currency_rate(self.currency, :USD)
      self.spend_in_usd  = (spend || 0)  * rate
      self.budget_in_usd = (budget || 0) * rate
    end
end
