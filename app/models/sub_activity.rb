class SubActivity < Activity

  # Associations
  belongs_to :activity, :counter_cache => true

  # Attributes
  attr_accessible :activity_id, :spend_percentage, :budget_percentage

  # Callbacks
  after_create  :update_counter_cache
  after_destroy :update_counter_cache

  #TODO: refactor
  [:projects, :name, :description,  :start, :end,
   :text_for_beneficiaries, :beneficiaries, :text_for_targets,
   :approved].each do |method|
    delegate method, :to => :activity, :allow_nil => true
  end

  def locations
    if provider
      if !provider.locations.empty?
        provider.locations
      elsif activity
        activity.locations
      else
        []
      end
    elsif activity
      activity.locations
    else
      []
    end
  end

  def budget
    if read_attribute(:budget)
     read_attribute(:budget)
    elsif budget_percentage && activity
     activity.budget.try(:*, budget_percentage / 100)
    else
     nil
    end
  end

  def spend
    if read_attribute(:spend)
     read_attribute(:spend)
    elsif spend_percentage && activity
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

  # use to populate the tables with correct values
  # then comment out and allow correct rows to work their magic
  # then use SQL to create reports for now
  def code_assignments
    # store in a cached variable as well
    if @code_assignments_cache
      @code_assignments_cache
    else
      unless activity.nil?
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
  end

  def get_district_coding type
    # if the provider is a clinic or hospital it has only one location
    # so put all the money towards that location
    coding_type = "Coding#{type.to_s.capitalize}District"
    if locations.size == 1 && self.send(type) && self.send(type)>0
      ca=CodeAssignment.new
      ca.cached_amount = self.send(type)
      ca.code_id = locations.first.id
      ca.type = coding_type
      ca.activity_id = id
      [ca]
    else
      unless activity.nil?
        cas = activity.code_assignments.with_type(coding_type)
        get_assignments_w_adjusted_amounts type, cas
      else
        []
      end
    end
  end

  def get_assignments_w_adjusted_amounts amount_method, assignments
    if self.send(amount_method).nil? or self.send(amount_method) <= 0
      []
    else
      new_assignments = []
      assignments.each do |ca|
        new_ca = CodeAssignment.new
        new_ca.type = ca.type
        new_ca.code_id = ca.code_id
        new_ca.cached_amount = self.send(amount_method) * ca.calculated_amount / activity.send(amount_method)
        new_ca.activity_id = self.id
        new_assignments << new_ca
      end
      new_assignments
    end
  end

  private
  def update_counter_cache
    self.data_response.sub_activities_count = data_response.sub_activities.count
    self.data_response.save(false)
  end
end

# == Schema Information
#
# Table name: activities
#
#  id                                    :integer         primary key
#  name                                  :string(255)
#  created_at                            :timestamp
#  updated_at                            :timestamp
#  provider_id                           :integer
#  description                           :text
#  type                                  :string(255)
#  budget                                :decimal(, )
#  spend_q1                              :decimal(, )
#  spend_q2                              :decimal(, )
#  spend_q3                              :decimal(, )
#  spend_q4                              :decimal(, )
#  start                                 :date
#  end                                   :date
#  spend                                 :decimal(, )
#  text_for_provider                     :text
#  text_for_targets                      :text
#  text_for_beneficiaries                :text
#  spend_q4_prev                         :decimal(, )
#  data_response_id                      :integer
#  activity_id                           :integer
#  budget_percentage                     :decimal(, )
#  spend_percentage                      :decimal(, )
#  approved                              :boolean
#  CodingBudget_amount                   :decimal(, )     default(0.0)
#  CodingBudgetCostCategorization_amount :decimal(, )     default(0.0)
#  CodingBudgetDistrict_amount           :decimal(, )     default(0.0)
#  CodingSpend_amount                    :decimal(, )     default(0.0)
#  CodingSpendCostCategorization_amount  :decimal(, )     default(0.0)
#  CodingSpendDistrict_amount            :decimal(, )     default(0.0)
#  use_budget_codings_for_spend          :boolean         default(FALSE)
#  budget_q1                             :decimal(, )
#  budget_q2                             :decimal(, )
#  budget_q3                             :decimal(, )
#  budget_q4                             :decimal(, )
#  budget_q4_prev                        :decimal(, )
#

