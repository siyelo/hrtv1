class CodeAssignment < ActiveRecord::Base
  include NumberHelper

  strip_commas_from_all_numbers

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
  named_scope :with_types,
              lambda { |types| { :conditions =>
                ["code_assignments.type IN (?)", types]} }
  named_scope :cached_amount_desc, {
              :order => "code_assignments.cached_amount DESC" }
  named_scope :select_for_pies,
              :select => "code_assignments.code_id,
                          SUM(code_assignments.cached_amount_in_usd) AS value",
              :include => :code,
              :group => 'code_assignments.code_id',
              :order => 'value DESC'
              
  named_scope :with_request,
              lambda { |request_id| { 
                :joins =>
                  "INNER JOIN activities ON
                    activities.id = code_assignments.activity_id
                  INNER JOIN data_responses
                    ON activities.data_response_id = data_responses.id
                  INNER JOIN data_requests
                    ON data_responses.data_request_id = data_requests.id AND 
                    data_responses.data_request_id = #{request_id}",
              }}

  
  ### Callbacks
  before_save :update_cached_amount_in_usd

  ### Delegates
  delegate :data_response, :to => :activity
  delegate :currency, :to => :activity, :allow_nil => true

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
    number_string.to_s.gsub(delimiter,'')
  end

  def self.download_template(klass)
    max_level = klass.deepest_nesting
    FasterCSV.generate do |csv|
      header_row = (['Code'] * max_level).concat(['Percentage', 'Amount', 'Code', 'Description'])
      (100 - header_row.length).times{ header_row << nil}
      header_row << 'Id'
      csv << header_row
      klass.roots.each{|code| add_rows(csv, code, max_level, 0)}
    end
  end

  def self.create_from_file(doc, activity, coding_type)
    updates = HashWithIndifferentAccess.new
    doc.each do |row|
      percentage = row['Percentage']
      amount     = row['Amount']
      id         = row['Id']

      code = Code.find(id)

      if (code && (amount.present? || percentage.present?))
        updates[code.id.to_s] = HashWithIndifferentAccess.new({:amount => amount,
                                                               :percentage => percentage})
      end
    end

    klass = coding_type.constantize
    klass.update_codings(updates, activity)
  end

  def self.add_rows(csv, code, max_level, current_level)
    row = []

    current_level.times{|i| row << '' }
    row << code.short_display
    (max_level - (current_level + 1)).times{ |i| row << '' }
    row << ''
    row << ''
    row << code.short_display
    row << code.description

    (100 - row.length).times{ row << nil}
    row << code.id

    csv << row

    code.children.each{|code| add_rows(csv, code, max_level, current_level + 1)}
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
      code_assignments.delete_if { |key,val| val["amount"].blank? && val["percentage"].blank? }
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

    # currency is derived from the parent activity/project/DR
    def update_cached_amount_in_usd
      self.cached_amount_in_usd = (cached_amount || 0) * currency_rate(currency, :USD)
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
#  activity_id          :integer         indexed => [code_id, type]
#  code_id              :integer         indexed, indexed => [activity_id, type]
#  amount               :decimal(, )
#  type                 :string(255)     indexed => [activity_id, code_id]
#  percentage           :decimal(, )
#  cached_amount        :decimal(, )     default(0.0)
#  sum_of_children      :decimal(, )     default(0.0)
#  created_at           :datetime
#  updated_at           :datetime
#  cached_amount_in_usd :decimal(, )     default(0.0)
#

