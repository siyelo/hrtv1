class CodeAssignment < ActiveRecord::Base

  include NumberHelper #TODO: deprecate with Money methods
  include MoneyHelper

  ### Associations
  belongs_to :activity
  belongs_to :code

  ### Validations
  validates_presence_of :activity_id, :code_id

  ### Attributes
  attr_accessible :activity, :code, :amount, :percentage,
                  :cached_amount, :sum_of_children

  # the _in_usd column needs to be synchronized across all objects regularly
  # otherwise different exchange rates will apply since this field is
  # normalized (using lates exchange rate) when each record is saved
  attr_accessible :new_cached_amount_in_usd

  ### ValueObject Attributes
  composed_of :new_amount,
              {:mapping => [%w(new_amount_cents cents),
                            %w(new_amount_currency currency_as_string)]
              }.merge(MONEY_OPTS)
  # cached amount could probably just reuse the amount currency
  # but included here for simplicity
  composed_of :new_cached_amount,
              {:mapping => [%w(new_cached_amount_cents cents),
                            %w(new_cached_amount_currency currency_as_string)]
              }.merge(MONEY_OPTS)

  ### Named scopes
  named_scope :with_code_ids,
              lambda { |code_ids| { :conditions =>
                ["code_assignments.code_id IN (?)", code_ids]} }
  named_scope :with_activity,
              lambda { |activity_id| { :conditions =>
                ["code_assignments.activity_id = ?", activity_id]} }
  named_scope :with_activities,
              lambda { |activity_ids|{ :conditions =>
                ["code_assignments.activity_id in (?)", activity_ids]} }
  named_scope :with_activities_include_implementer,
              lambda { |activity_ids| {
                :conditions => ["code_assignments.activity_id in (?)", activity_ids],
                :joins => [:activity => :provider]} }
  named_scope :with_type,
              lambda { |type| { :conditions =>
                ["code_assignments.type = ?", type]} }
  named_scope :with_code_id,
              lambda { |code_id| { :conditions =>
                ["code_assignments.code_id = ?", code_id]} }
  named_scope :sort_cached_amt, { :order => "code_assignments.cached_amount DESC"}
  named_scope :with_location,
              lambda { |location_id| { :conditions =>
                ["code_assignments.code_id = ?", location_id]} }
  named_scope :select_for_pies,
              :select => "code_assignments.code_id, SUM(code_assignments.new_cached_amount_in_usd/100) AS value",
              :include => :code,
              :group => 'code_assignments.code_id',
              :order => 'value DESC'


  ### Callbacks
  before_save :update_money_amounts

  ### Class Methods

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
      children = ac.children
      if ca
        if ca.amount.present? && ca.amount > 0
          my_cached_amount = ca.amount
          sum_of_children = self.codings_sum(children, activity, max)
          ca.update_attributes(:cached_amount => my_cached_amount, :sum_of_children => sum_of_children) #if my_cached_amount > 0 or sum_of_children > 0
        elsif ca.percentage.present? && ca.percentage > 0
          my_cached_amount = ca.percentage * max / 100
          sum_of_children = self.codings_sum(children, activity, max)
          ca.update_attributes(:cached_amount => my_cached_amount, :sum_of_children => sum_of_children) #if my_cached_amount > 0 or sum_of_children > 0
        else
          sum_of_children = my_cached_amount = self.codings_sum(children, activity, max)
          ca.update_attributes(:cached_amount => my_cached_amount, :sum_of_children => sum_of_children) #if my_cached_amount > 0 or sum_of_children > 0
        end
      else
        sum_of_children = my_cached_amount = self.codings_sum(children, activity, max)
        self.create!(:activity => activity, :code => ac, :cached_amount => my_cached_amount) if sum_of_children > 0
      end
      total += my_cached_amount
    end
    total
  end


  ### Instance Methods

  # override this in subclasses to make proportion work
  def activity_amount
    #TODO add a class that has a unique name
    # so its easy to telll that this method
    # wasnt implemented
    # this class should error on any method
    "default crappy value that will break code"
  end

  def proportion_of_activity
    unless activity_amount == 0 or calculated_amount.nil? or calculated_amount == 0
      calculated_amount / activity_amount
    else
      if !percentage.nil?
        percentage / 100
      else
        0
      end
    end
  end

  def calculated_amount
    return cached_amount unless cached_amount.nil?
    return 0
  end

  def code_name
    code.short_display
  end

  def currency
    self.activity.nil? ? nil : self.activity.currency
  end

  def calculated_amount_currency
    n2c(self.calculated_amount, self.currency).to_s
  end

  def self.sums_by_code_id(code_ids, coding_type, activities)
    CodeAssignment.with_code_ids(code_ids).with_type(coding_type).with_activities(activities).find(:all,
      :select => 'code_assignments.code_id, code_assignments.activity_id, SUM(code_assignments.new_cached_amount_in_usd) AS value',
      :group => 'code_assignments.code_id, code_assignments.activity_id',
      :order => 'value DESC'
    ).group_by{|ca| ca.code_id}
  end

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
      activity.update_classified_amount_cache(self)
    end
  end

  protected

    #currency is still derived from the parent activities' project/DR
    def update_money_amounts
      if currency
        zero = BigDecimal.new("0")
        self.new_amount        = Money.from_bigdecimal(self.amount || zero, currency)
        self.new_cached_amount = Money.from_bigdecimal(self.cached_amount || zero, currency)
        self.new_cached_amount_in_usd = self.new_cached_amount.exchange_to(:USD).cents
      end
    end
end



# == Schema Information
#
# Table name: code_assignments
#
#  id                         :integer         not null, primary key
#  activity_id                :integer
#  code_id                    :integer         indexed
#  amount                     :decimal(, )
#  type                       :string(255)
#  percentage                 :decimal(, )
#  cached_amount              :decimal(, )     default(0.0)
#  sum_of_children            :decimal(, )     default(0.0)
#  new_amount_cents           :integer         default(0), not null
#  new_amount_currency        :string(255)
#  new_cached_amount_cents    :integer         default(0), not null
#  new_cached_amount_currency :string(255)
#  new_cached_amount_in_usd   :integer         default(0), not null
#

