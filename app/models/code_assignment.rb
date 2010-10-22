class CodeAssignment < ActiveRecord::Base

  ### Associations
  belongs_to :activity
  belongs_to :code
  ### Validations
  validates_presence_of :activity, :code
  ### Attributes
  attr_accessible :activity, :code, :amount, :percentage, :cached_amount, :sum_of_children

  ### Named scopes
  named_scope :with_code_ids,   lambda { |code_ids| {:conditions => ["code_assignments.code_id IN (?)", code_ids]} }
  named_scope :with_activity,   lambda { |activity_id| {:conditions => ["activity_id = ?", activity_id]} }
  named_scope :with_activities, lambda { |activity_ids|{:conditions => ["activity_id in (?)", activity_ids]} }
  named_scope :with_type,       lambda { |type| {:conditions => ["code_assignments.type = ?", type]} }
  named_scope :with_code_id,    lambda { |code_id| {:conditions => ["code_assignments.code_id = ?", code_id]} }
  ### methods

  def self.leaf_assigns_for_activities(activities)
    self.with_type(self.to_s).with_activities(activities).find(:all, :conditions => ["sum_of_children = 0"])
  end

  def calculated_amount
    if read_attribute(:amount).nil?
      cached_amount
    else
      read_attribute(:amount)
    end
  end

  def self.update_codings(code_assignments, activity)
    if code_assignments
      code_assignments.delete_if { |key,val| val["amount"].nil? || val["percentage"].nil? }
      code_assignments.delete_if { |key,val| val["amount"].empty? && val["percentage"].empty? }
      selected_codes = code_assignments.nil? ? [] : code_assignments.keys.collect{ |id| Code.find_by_id(id) }

      self.with_activity(activity.id).delete_all

      # TODO update all the codings, create the ones that are actually new
      selected_codes.each do |code|
        self.create!(
          :activity => activity,
          :code => code,
          :amount => currency_to_number(code_assignments[code.id.to_s]["amount"]),
          :percentage => code_assignments[code.id.to_s]["percentage"]
        ) if code
      end

      if activity.use_budget_codings_for_spend
        budget_type = self.to_s
        activity.copy_budget_codings_to_spend([budget_type]) # copy the same budget codings to spend
        spend_type = budget_type.gsub(/Budget/, "Spend") # get appropriate spend type
        activity.update_classified_amount_cache(self) # update cache for budget
        activity.update_classified_amount_cache(spend_type.constantize) # update cache for spend
      else
        activity.update_classified_amount_cache(self)
      end
    end
  end

  # assumes a format like "17,798,123.00"
  def self.currency_to_number(number_string, options ={})
    options.symbolize_keys!
    defaults  = I18n.translate(:'number.format', :locale => options[:locale], :raise => true) rescue {}
    currency  = I18n.translate(:'number.currency.format', :locale => options[:locale], :raise => true) rescue {}
    defaults  = defaults.merge(currency)
    delimiter = options[:delimiter] || defaults[:delimiter]

    number_string.gsub(delimiter,'')
  end

  def self.codings_sum(available_codes, activity, max)
    total = 0
    max = 0 if max.nil?
    my_cached_amount = 0

    available_codes.each do |ac|
      ca = self.with_activity(activity).with_code_id(ac.id).first

      if ca
        if ca.amount.present? && ca.amount > 0
          my_cached_amount = ca.amount
          sum_of_children = self.codings_sum(ac.children, activity, max)
          ca.update_attributes(:cached_amount => my_cached_amount, :sum_of_children => sum_of_children) #if my_cached_amount > 0 or sum_of_children > 0
        elsif ca.percentage.present? && ca.percentage > 0
          my_cached_amount = ca.percentage * max / 100
          sum_of_children = self.codings_sum(ac.children, activity, max)
          ca.update_attributes(:cached_amount => my_cached_amount, :sum_of_children => sum_of_children) #if my_cached_amount > 0 or sum_of_children > 0
        else
          sum_of_children = my_cached_amount = self.codings_sum(ac.children, activity, max)
          ca.update_attributes(:cached_amount => my_cached_amount, :sum_of_children => sum_of_children) #if my_cached_amount > 0 or sum_of_children > 0
        end
      else
        sum_of_children = my_cached_amount = self.codings_sum(ac.children, activity, max)
        self.create!(:activity => activity, :code => ac, :cached_amount => my_cached_amount) if sum_of_children > 0
      end

      total += my_cached_amount
    end

    total
  end

  def self.copy_coding_from_budget_to_spend assignments, new_klass, save = true
    new_assignments = []
    #make new code assignments
    #shift values to correct amount
    #save them
    assignments.each do |ca|
      activity = assignments.first.activity
      new_ca = new_klass.new
      new_ca.code_id = ca.code_id
      conversion_ratio = activity.spend / activity.budget
      new_ca.cached_amount = ca.calculated_amount * conversion_ratio
      new_ca.sum_of_children = ca.sum_of_children * conversion_ratio
      new_ca.percentage = ca.percentage if ca.percentage
      new_ca.activity = activity
      new_ca.save
      new_assignments << new_ca
    end
    new_assignments
  end
end

# == Schema Information
#
# Table name: code_assignments
#
#  id            :integer         primary key
#  activity_id   :integer
#  code_id       :integer
#  code_type     :string(255)
#  amount        :decimal(, )
#  type          :string(255)
#  percentage    :decimal(, )
#  cached_amount :decimal(, )
#

