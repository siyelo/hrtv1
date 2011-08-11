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
  validates_inclusion_of :percentage, :in => 1..100,
    :if => Proc.new { |model| model.percentage.present? }

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

  def self.download_template(klass)
    max_level = klass.deepest_nesting
    FasterCSV.generate do |csv|
      header_row = (['Code'] * max_level).concat(['Past Expenditure', 'Current Budget', 'Code', 'Description'])
      (100 - header_row.length).times{ header_row << nil}
      header_row << 'Id'
      csv << header_row
      klass.roots.each{|code| add_rows(csv, code, max_level, 0)}
    end
  end

  def self.create_from_file(doc, activity, budget_klass, spend_klass)
    budget_updates = {}
    spend_updates  = {}
    doc.each do |row|
      spend   = row['Past Expenditure']
      budget  = row['Current Budget']
      code_id = row['Id']

      budget_updates[code_id] = budget if code_id && budget.present?
      spend_updates[code_id]  = spend if code_id && spend.present?
    end

    budget_klass.update_classifications(activity, budget_updates)
    spend_klass.update_classifications(activity, spend_updates)
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

  def self.update_classifications(activity, classifications)
    present_ids = []
    assignments = self.with_activity(activity.id)
    codes       = Code.find(classifications.keys)

    classifications.each_pair do |code_id, value|
      code = codes.detect{|code| code.id == code_id.to_i}

      if value.present?
        present_ids << code_id

        ca = assignments.detect{|ca| ca.code_id == code_id.to_i}

        # initialize new code assignment if it does not exist
        ca = self.new(:activity => activity, :code => code) unless ca
        ca.percentage = value
        ca.save
      end
    end

    # SQL deletion, faster than deleting records individually
    if present_ids.present?
      self.delete_all(["activity_id = ? AND code_id NOT IN (?)",
                                 activity.id, present_ids])
    else
      self.delete_all(["activity_id = ?", activity.id])
    end

    activity.update_classified_amount_cache(self)
  end




  def cached_amount
    self[:cached_amount] || 0
  end

  ### Instance Methods

  def aggregate_amount
    cached_amount
  end

  def amount_not_in_children
    sum_of_children.nil? ? cached_amount : cached_amount - sum_of_children
  end

  def has_amount_not_in_children?
    cached_amount - sum_of_children > 0 ? true : false
  end

  # NOTE: in this method we use amounts in USD
  # because those amounts are in the GOR FY
  def proportion_of_activity
    activity_amount_in_usd = budget? ?
      (activity.try(:budget_in_usd) || 0) : (activity.try(:spend_in_usd) || 0)

    if activity_amount_in_usd > 0 && cached_amount_in_usd > 0
      cached_amount_in_usd / activity_amount_in_usd
    else
      percentage ? percentage / 100 : 0
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
#  code_id              :integer         indexed => [activity_id, type], indexed
#  amount               :decimal(, )
#  type                 :string(255)     indexed => [activity_id, code_id]
#  percentage           :decimal(, )
#  cached_amount        :decimal(, )     default(0.0)
#  sum_of_children      :decimal(, )     default(0.0)
#  created_at           :datetime
#  updated_at           :datetime
#  cached_amount_in_usd :decimal(, )     default(0.0)
#

