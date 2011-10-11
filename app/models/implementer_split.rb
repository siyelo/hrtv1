 class ImplementerSplit < ActiveRecord::Base
  include NumberHelper
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
  named_scope :sorted, {:joins => [:organization], :order => "organizations.name"}

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
    write_attribute(:budget, is_number?(amount) ? amount.to_f.round_with_precision(2) : amount)
  end

  def spend=(amount)
    write_attribute(:spend, is_number?(amount) ? amount.to_f.round_with_precision(2) : amount)
  end

  def possible_duplicate?
    # NOTE: optimize provider.projects.count call
    organization && organization != activity.organization &&
      organization.reporting? && organization.projects.count > 0
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
#

