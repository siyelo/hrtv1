# == Schema Information
#
# Table name: code_assignments
#
#  id          :integer         not null, primary key
#  activity_id :integer
#  code_id     :integer
#  code_type   :string(255)
#  amount      :decimal(, )
#  type        :string(255)
#  percentage  :decimal(, )
#
class CodeAssignment < ActiveRecord::Base

  # Associations
  belongs_to :activity
  belongs_to :code
# Validations
  validates_presence_of :activity, :code

  # Attributes
  attr_accessible :activity, :code, :amount, :percentage, :cached_amount

  def calculated_amount
    if read_attribute(:amount).nil?
      cached_amount
    else
      read_attribute(:amount) 
    end
  end

  # Named scopes
  named_scope :with_code_ids, lambda { |code_ids| {:conditions => ["code_assignments.code_id IN (?)", code_ids]} }
  named_scope :with_activity, lambda { |activity_id| {:conditions => ["activity_id = ?", activity_id]} }
  named_scope :with_type,     lambda { |type| {:conditions => ["code_assignments.type = ?", type]} }
  named_scope :with_code_id,  lambda { |code_id| {:conditions => ["code_assignments.code_id = ?", code_id]} }

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
      activity.update_classified_amount_cache self
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
      code_assignments = self.with_activity(activity).with_code_id(ac.id)
      raise "Duplicate code assignments".to_yaml if code_assignments.length > 1
      ca = code_assignments.first
      if ca
        if ca.amount.present? && ca.amount > 0
          my_cached_amount = ca.amount
        elsif ca.percentage.present? && ca.percentage > 0
          my_cached_amount = ca.percentage * max / 100
        end
        #ca.update_attributes :cached_amount => my_cached_amount
        ca.cached_amount = my_cached_amount
        ca.save!
        total += my_cached_amount 
        self.codings_sum(ac.children, activity, max)
      elsif !ac.leaf?
        my_cached_amount = self.codings_sum(ac.children, activity, max)
        self.create!(
          :activity => activity,
          :code => ac,
          :cached_amount => my_cached_amount
        ) if my_cached_amount > 0
        total += my_cached_amount
      end
    end

    total
  end

  def self.copy_coding_from_budget_to_spend coding, save = true
    new_assignments = []
    #make new code assignments
    #shift values to correct amount
    #save them
    type = new_assignments.to_s.gsub("Budget","Spend").constantize
    assignments.each do |ca|
      activity = assignments.first.activity
      new_ca = type.new
      new_ca.type = ca.type
      new_ca.code_id = ca.code_id
      new_ca.cached_amount = activity.spend * ca.calculated_amount / activity.budget
      new_ca.activity_id = self.id
      new_assignments << new_ca
    end
    new_assignments
  end
end
