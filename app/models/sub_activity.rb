# == Schema Information
#
# Table name: activities
#
#  id                     :integer         not null, primary key
#  name                   :string(255)
#  beneficiary            :string(255)
#  target                 :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  provider_id            :integer
#  other_cost_type_id     :integer
#  description            :text
#  type                   :string(255)
#  budget                 :decimal(, )
#  spend_q1               :decimal(, )
#  spend_q2               :decimal(, )
#  spend_q3               :decimal(, )
#  spend_q4               :decimal(, )
#  start                  :date
#  end                    :date
#  spend                  :decimal(, )
#  text_for_provider      :text
#  text_for_targets       :text
#  text_for_beneficiaries :text
#  spend_q4_prev          :decimal(, )
#  data_response_id       :integer
#  activity_id            :integer
#  budget_percentage      :decimal(, )
#  spend_percentage       :decimal(, )
#


#require 'lib/ActAsDataElement' #super class already has it mixed in

class SubActivity < Activity
  belongs_to :activity
  attr_accessible :activity_id, :spend_percentage, :budget_percentage
  
  [:projects, :name, :description,  :start, :end,
   :text_for_beneficiaries, :beneficiaries, :text_for_targets, 
   :approved].each do |method|
    delegate method, :to => :activity
  end

  def locations
    if provider
      unless provider.locations.empty?
        provider.locations
      else
        activity.locations
      end
    else
      activity.locations
    end
  end
 
  def budget
    if read_attribute(:budget)
     read_attribute(:budget)
    elsif budget_percentage
     activity.budget.try(:*, budget_percentage / 100)
    else
     nil
    end
  end

  def spend
    if read_attribute(:spend)
     read_attribute(:spend)
    elsif spend_percentage
     activity.spend.try(:*, spend_percentage / 100)
    else
     nil
    end
  end


  def budget_coding
    code_assignments.select {|ca| ca.type == "CodingBudget"} 
  end

  def budget_district_coding
    code_assignments.select {|ca| ca.type == "CodingBudgetDistrict"}
  end

  def budget_cost_category_coding
    code_assignments.select {|ca| ca.type == "CodingBudgetCostCategorization"}
  end

  def spend_coding
    code_assignments.select {|ca| ca.type == "CodingSpend"}
  end

  def spend_district_coding
    code_assignments.select {|ca| ca.type == "CodingSpendDistrict"}
  end

  def spend_cost_category_coding
    code_assignments.select {|ca| ca.type == "CodingSpendCostCategorization"}
  end

  def code_assignments
    # store in a cached variable as well
    if @code_assignments_cache
      @code_assignments_cache
    else
      @code_assignments_cache = []
      # change amounts to reflect this subactivity
      budget_district_coding = get_district_coding :budget
      budget_coding = get_assignments_w_adjusted_amounts :budget, activity.code_assignments.with_type("CodingBudget")
      budget_coding_categories = get_assignments_w_adjusted_amounts :budget, activity.code_assignments.with_type("CodingBudgetCostCategorization")
      
      spend_district_coding = get_district_coding :spend
      spend_coding = get_assignments_w_adjusted_amounts :spend, activity.code_assignments.with_type("CodingSpend")
      spend_coding_categories = get_assignments_w_adjusted_amounts :spend, activity.code_assignments.with_type("CodingSpendCostCategorization")

      [budget_district_coding, budget_coding, budget_coding_categories,
       spend_district_coding, spend_coding, spend_coding_categories].each do |cas|
        @code_assignments_cache << cas
       end
       @code_assignments_cache = @code_assignments_cache.flatten
    end
  end

  def get_district_coding type
    # if the provider is a clinic or hospital it has only one location
    # so put all the money towards that location
    coding_type = "Coding#{type.to_s.capitalize}District"
    if locations.size == 1
      [CodeAssignment.new :cached_amount => self.send(type),
         :code_id => locations.first.id, :type => coding_type,
         :activity_id => id]
    else
      cas = activity.code_assignments.with_type(coding_type)
      get_assignments_w_adjusted_amounts type, cas
    end
  end

  def get_assignments_w_adjusted_amounts amount_method, assignments
      assignments.collect {|ca| ca.cached_amount = self.send(amount_method); ca}
  end
end
