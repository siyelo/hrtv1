require 'validation_disabler'
class Organization < ActiveRecord::Base

  acts_as_commentable

  has_many :users # people in this organization
  has_and_belongs_to_many :activities # activities that target / aid this org
  has_many :data_requests_made,
           :class_name => "DataRequest",
           :foreign_key => :organization_id_requester
  has_many :data_responses, :foreign_key => :organization_id_responder, :dependent => :destroy
  has_many :dr_activities, :through => :data_responses, :source => :activities
  has_many :out_flows,
            :class_name => "FundingFlow",
            :foreign_key => "organization_id_from"
  has_many :in_flows,
            :class_name => "FundingFlow",
            :foreign_key => "organization_id_to"
  has_many :donor_for, :through => :out_flows, :source => :project
  has_many :implementor_for, :through => :in_flows, :source => :project
  has_many :provider_for, :class_name => "Activity", :foreign_key => :provider_id
  has_and_belongs_to_many :locations

  attr_accessible :name

  validates_presence_of :name
  validates_uniqueness_of :name

  def self.remove_security
    with_exclusive_scope { find(:all) }
  end

  def self.top_by_spent_and_budget(options)
    per_page = options[:per_page] || 25
    page     = options[:page]     || 1
    code_ids = options[:code_ids]
    type     = options[:type]
    sort     = options[:sort]

    raise "Missing code_ids param".to_yaml if code_ids.blank? ||
      !code_ids.kind_of?(Array)
    raise "Missing type param".to_yaml if type.blank? &&
      (type != 'district' || type != 'country')
    raise "Invalid sort type" if !sort.blank? &&
      !['spent_asc', 'spent_desc', 'budget_asc', 'budget_desc'].include?(sort)

    ca1_type = (type == 'district') ? 'CodingSpendDistrict' : 'CodingSpend'
    ca2_type = (type == 'district') ? 'CodingBudgetDistrict' : 'CodingBudget'
    code_ids = code_ids.join(',')

    scope = self.scoped({
      :select => "organizations.id,
                  organizations.name,
                  COALESCE(SUM(spent_sum),0) as spent_sum,
                  COALESCE(SUM(budget_sum),0) as budget_sum",
      :joins => "
        INNER JOIN data_responses ON organizations.id = data_responses.organization_id_responder
        INNER JOIN activities ON data_responses.id = activities.data_response_id
        LEFT OUTER JOIN (
          SELECT ca1.activity_id, SUM(ca1.cached_amount_in_usd) as spent_sum
          FROM code_assignments ca1
          WHERE ca1.type = '#{ca1_type}'
          AND ca1.code_id IN (#{code_ids})
          GROUP BY ca1.activity_id
        ) ca1 ON activities.id = ca1.activity_id
        LEFT OUTER JOIN (
          SELECT ca2.activity_id, SUM(ca2.cached_amount_in_usd) as budget_sum
          FROM code_assignments ca2
          WHERE ca2.type = '#{ca2_type}'
          AND ca2.code_id IN (#{code_ids})
          GROUP BY ca2.activity_id
        ) ca2 ON activities.id = ca2.activity_id",
      :group => "organizations.id,
                 organizations.name",
      :order => SortOrder.get_sort_order(sort),
      :conditions => "spent_sum > 0 OR budget_sum > 0"
    })

    scope.paginate :all, :per_page => per_page, :page => page
  end

  def self.top_by_spent(options)
    limit    = options[:limit]    || nil
    code_ids = options[:code_ids]
    type     = options[:type]

    raise "Missing code_ids param".to_yaml if code_ids.blank? || !code_ids.kind_of?(Array)
    raise "Missing type param".to_yaml if type.blank? && (type != 'district' || type != 'country')

    ca_type = (type == 'district') ? 'CodingSpendDistrict' : 'CodingSpend'
    code_ids = code_ids.join(',')

    scope = self.scoped({
      :select => "organizations.id,
                  organizations.name,
                  SUM(ca1.cached_amount_in_usd) as spent_sum",
      :joins => "
        INNER JOIN data_responses ON organizations.id = data_responses.organization_id_responder
        INNER JOIN activities ON data_responses.id = activities.data_response_id
        INNER JOIN code_assignments ca1 ON activities.id = ca1.activity_id
          AND ca1.type = '#{ca_type}'
          AND ca1.code_id IN (#{code_ids})",
      :group => "organizations.id,
                 organizations.name",
      :order => "spent_sum DESC"
    })

    scope.find :all, :limit => limit
  end

  # Named scopes
  named_scope :without_users, :conditions => 'users_count = 0'
  named_scope :ordered, :order => 'name ASC, created_at DESC'

  def is_empty?
    if users.empty? && in_flows.empty? && out_flows.empty? && provider_for.empty? && locations.empty? && activities.empty? && data_responses.select{|dr| dr.empty?}.length == data_responses.size
      true
    else
      false
    end
  end

  def self.merge_organizations!(target, duplicate)
    ActiveRecord::Base.disable_validation!
    target.activities << duplicate.activities
    target.data_requests_made << duplicate.data_requests_made
    target.data_responses << duplicate.data_responses
    target.out_flows << duplicate.out_flows
    target.in_flows << duplicate.in_flows
    target.provider_for << duplicate.provider_for
    target.locations << duplicate.locations
    target.users << duplicate.users
    duplicate.reload.destroy # reload other organization so that it does not remove the previously assigned data_responses
    ActiveRecord::Base.enable_validation!
  end

  def to_s
    name
  end

  def user_email_list_limit_3
    users[0,2].collect{|u| u.email}.join ","
  end

  def short_name
    #TODO remove district name in (), capitalized, and as below
    n = name.gsub("| "+locations.first.to_s, "") unless locations.empty?
    n ||= name
    n = n.gsub("Health Center", "HC")
    n = n.gsub("District Hospital", "DH")
    n = n.gsub("Health Post", "HP")
    n = n.gsub("Dispensary", "Disp")
    n
  end

end


# == Schema Information
#
# Table name: organizations
#
#  id             :integer         primary key
#  name           :string(255)
#  type           :string(255)
#  created_at     :timestamp
#  updated_at     :timestamp
#  raw_type       :string(255)
#  fosaid         :string(255)
#  users_count    :integer         default(0)
#  comments_count :integer         default(0)
#

