class CodeAssignment < ActiveRecord::Base

  ### Attributes
  attr_accessible :activity, :code, :amount, :percentage,
                  :sum_of_children, :cached_amount, :cached_amount_in_usd

  ### Associations
  belongs_to :activity
  belongs_to :code

  ### Validations
  validates_presence_of :activity_id, :code_id

  ### Named scopes
  named_scope :with_code_id,
              lambda { |code_id| { :conditions =>
                ["code_assignments.code_id = ?", code_id]} }
  named_scope :with_code_ids,
              lambda { |code_ids| { :conditions =>
                ["code_assignments.code_id IN (?)", code_ids]} }
  named_scope :with_activity,
              lambda { |activity_id| { :conditions =>
                ["code_assignments.activity_id = ?", activity_id]} }
  named_scope :with_activities,
              lambda { |activity_ids|{ :conditions =>
                ["code_assignments.activity_id in (?)", activity_ids]} }
  named_scope :with_type,
              lambda { |type| { :conditions =>
                ["code_assignments.type = ?", type]} }
  named_scope :cached_amount_desc, {
              :order => "code_assignments.cached_amount DESC" }
  named_scope :select_for_pies,
              :select => "code_assignments.code_id,
                          SUM(code_assignments.cached_amount_in_usd) AS value",
              :include => :code,
              :group => 'code_assignments.code_id',
              :order => 'value DESC'

  ### Callbacks
  before_save :update_cached_amount_in_usd

  ### Delegates
  delegate :data_response, :to => :activity

  ### Class Methods
  #

  # assumes a format like "17,798,123.00"
  # TODO: spec
  def self.currency_to_number(number_string, options ={})
    options.symbolize_keys!
    defaults  = I18n.translate(:'number.format', :locale => options[:locale], :raise => true) rescue {}
    currency  = I18n.translate(:'number.currency.format', :locale => options[:locale], :raise => true) rescue {}
    defaults  = defaults.merge(currency)
    delimiter = options[:delimiter] || defaults[:delimiter]
    number_string.gsub(delimiter,'')
  end

  def aggregate_amount
    cached_amount
  end

  def amount_not_in_children
    sum_of_children.nil? ? cached_amount : cached_amount - sum_of_children
  end

  def has_amount_not_in_children?
    cached_amount - sum_of_children > 0 ? true : false
  end

  # TODO: spec
  def proportion_of_activity
    activity_amount = budget? ? (activity.try(:budget) || 0) : (activity.try(:spend) || 0)

    unless activity_amount == 0 or cached_amount.nil? or cached_amount == 0
      cached_amount / activity_amount
    else
      if !percentage.nil?
        percentage / 100
      else
        0
      end
    end
  end

  # TODO: spec
  def currency
    self.activity.nil? ? nil : self.activity.currency
  end

  # TODO: spec
  def self.sums_by_code_id(code_ids, coding_type, activities)
    CodeAssignment.with_code_ids(code_ids).with_type(coding_type).with_activities(activities).find(:all,
      :select => 'code_assignments.code_id, code_assignments.activity_id, SUM(code_assignments.cached_amount_in_usd) AS value',
      :group => 'code_assignments.code_id, code_assignments.activity_id',
      :order => 'value DESC'
    ).group_by{|ca| ca.code_id}
  end

  # TODO: spec
  def self.ratios_by_activity_id(code_id, activity_ids, district_type, activity_value)
    CodeAssignment.with_code_id(code_id).with_type(district_type).with_activities(activity_ids).find(:all,
      :joins => :activity,
      :select => "code_assignments.activity_id,
                  activities.#{activity_value},
                  (CAST(SUM(code_assignments.cached_amount) AS REAL) / CAST(activities.#{activity_value} AS REAL)) AS ratio",
      :group => "code_assignments.activity_id,
                 activities.#{activity_value}",
      :conditions => "activities.#{activity_value} > 0"
    ).group_by{|ca| ca.activity_id}
  end

  # TODO: spec
  def self.update_codings(code_assignments, activity)
    if code_assignments
      code_assignments.delete_if { |key,val| val["amount"].nil? || val["percentage"].nil? }
      code_assignments.delete_if { |key,val| val["amount"].empty? && val["percentage"].empty? }
      selected_codes = code_assignments.nil? ? [] : code_assignments.keys.collect{ |id| Code.find_by_id(id) }
      self.with_activity(activity.id).delete_all
      # if there are any codes, then save them!
      selected_codes.each do |code|
        self.create!(:activity => activity,
                     :code => code,
                     :amount => currency_to_number(code_assignments[code.id.to_s]["amount"]),
                     :percentage => code_assignments[code.id.to_s]["percentage"]
        )
      end

      # TODO: find what's the problem with this !
      # sum_of_children gets saved properly when this is called 2 times
      #
      activity.update_classified_amount_cache(self)
      activity.update_classified_amount_cache(self)
    end
  end

  private

    # currency is derived from the parent activities' project/DR
    def update_cached_amount_in_usd
      self.cached_amount_in_usd = (cached_amount || 0) * Money.default_bank.get_rate(self.currency, :USD)
    end

    # Checks if it's a budget code assignment
    def budget?
      ['CodingBudget',
       'CodingBudgetCostCategorization',
       'CodingBudgetDistrict',
       'HsspBudget'].include?(type.to_s)
    end
end






# == Schema Information
#
# Table name: code_assignments
#
#  id                   :integer         not null, primary key
#  activity_id          :integer
#  code_id              :integer         indexed
#  amount               :decimal(, )
#  type                 :string(255)
#  percentage           :decimal(, )
#  cached_amount        :decimal(, )     default(0.0)
#  sum_of_children      :decimal(, )     default(0.0)
#  created_at           :datetime
#  updated_at           :datetime
#  cached_amount_in_usd :decimal(, )     default(0.0)
#

