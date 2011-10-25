 class ImplementerSplit < ActiveRecord::Base
  include AutocreateHelper

  belongs_to :activity
  belongs_to :organization # the implementer

  attr_accessible :activity_id, :organization_id, :budget, :spend,
    :organization_mask, :organization

  ### Validations
  validates_presence_of :organization_mask
  # this seems to be bypassed on activity update if you pass two of the same orgs
  validates_uniqueness_of :organization_id, :scope => :activity_id,
    :message => "must be unique", :unless => Proc.new { |m| m.new_record? }
  validates_presence_of :organization_id
  validates_numericality_of :spend, :greater_than => 0,
    :if => Proc.new { |is| is.spend.present? && (!is.budget.present? || is.budget == 0) }
  validates_numericality_of :budget, :greater_than => 0,
    :if => Proc.new { |is| is.budget.present? && (!is.spend.present? || is.spend == 0) }
  validates_presence_of :spend, :message => " and/or Budget must be present",
    :if => lambda { |is| (!((is.budget || 0) > 0)) && (!((is.spend || 0) > 0)) }

  ### Delegates
  delegate :name, :to => :organization, :prefix => true, :allow_nil => true # gives you organization_name

  ### Named Scopes
  named_scope :implemented_by_health_centers, { :joins => [:organization],
    :conditions => ["organizations.raw_type = ?", "Health Center"]}
  named_scope :sorted, { :joins => "LEFT OUTER JOIN organizations ON
    organizations.id = implementer_splits.organization_id",
    :order => "LOWER(organizations.name) ASC"}

  ### Instance methods

  def organization_mask
    @organization_mask || organization_id
  end

  def organization_mask=(the_organization_mask)
    self.organization_id_will_change! # trigger saving of this model
    self.organization_id = self.assign_or_create_organization(the_organization_mask)
    @organization_mask   = self.organization_id
  end

  def budget=(amount)
    write_attribute(:budget, NumberHelper.is_number?(amount) ? amount.to_f.round_with_precision(2) : amount)
  end

  def spend=(amount)
    write_attribute(:spend, NumberHelper.is_number?(amount) ? amount.to_f.round_with_precision(2) : amount)
  end

  def possible_double_count?
    reporting_org         = activity.organization
    reporting_response    = activity.data_response
    implementing_org      = organization
    implementing_response = organization.data_responses.
      detect{|r| r.data_request_id = reporting_response.data_request_id }

    implementing_org && implementing_org != reporting_org &&
      implementing_org.reporting? && implementing_response.accepted? &&
      reporting_response.projects_count > 0
  end

  class << self
    def mark_double_counting(file)
      hash = {}
      rows = FasterCSV.parse(file, {:headers => true})

      rows.map do |row|
        hash[row['Implementer Split ID']] = row['Actual Double-Count?']
      end

      ImplementerSplit.find(:all, :conditions => ["id IN (?)", hash.keys]).each do |split|
        split.double_count = hash[split.id.to_s]
        split.save(false)
      end
    end
    handle_asynchronously :mark_double_counting
  end
end


# == Schema Information
#
# Table name: implementer_splits
#
#  id              :integer         not null, primary key
#  activity_id     :integer
#  organization_id :integer
#  spend           :decimal(, )
#  budget          :decimal(, )
#  created_at      :datetime
#  updated_at      :datetime
#  double_count    :boolean
#

