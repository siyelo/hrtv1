require 'validators'

class Organization < ActiveRecord::Base
  include ActsAsDateChecker

  ### Constants
  FILE_UPLOAD_COLUMNS = %w[name raw_type fosaid currency]

  ORGANIZATION_TYPES = ['Bilateral', 'Central Govt Revenue',
    'Clinic/Cabinet Medical', 'Communal FOSA', 'Dispensary', 'District',
    'District Hospital', 'Government', 'Govt Insurance', 'Health Center',
    'Health Post', 'International NGO', 'Local NGO', 'MOH central',
    'Military Hospital', 'MoH unit', 'Multilateral', 'National Hospital',
    'Non-Reporting', 'Other ministries', 'Parastatal', 'Prison Clinic',
    'RBC institutions']

  NON_REPORTING_TYPES = ['Clinic/Cabinet Medical', 'Communal FOSA',
    'Dispensary', 'District', 'District Hospital', 'Health Center',
    'Health Post', 'Non-Reporting', 'Other ministries', 'Prison Clinic']

  ### Attributes
  attr_accessible :name, :raw_type, :fosaid, :currency, :fiscal_year_end_date,
    :fiscal_year_start_date, :contact_name, :contact_position, :contact_phone_number,
    :contact_main_office_phone_number, :contact_office_location, :location_id

  ### Associations
  belongs_to :location
  has_many :users # people in this organization
  has_and_belongs_to_many :managers, :join_table => "organizations_managers",
    :class_name => "User" # activity managers
  has_many :data_requests
  has_many :data_responses, :dependent => :destroy
  has_many :dr_activities, :through => :data_responses, :source => :activities

  has_many :out_flows, :class_name => "FundingFlow",
             :foreign_key => "organization_id_from"
  has_many :donor_for, :through => :out_flows, :source => :project

  has_many :implementer_splits # this is NOT project.activity.implementer_splits

  # convenience
  has_many :projects, :through => :data_responses
  has_many :activities, :through => :data_responses

  ### Validations
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :currency, :contact_name, :contact_position,
                        :contact_office_location, :contact_phone_number,
                        :contact_main_office_phone_number, :on => :update
  validates_inclusion_of :currency, :in => Money::Currency::TABLE.map{|k, v| "#{k.to_s.upcase}"}, :on => :update
  validates_date :fiscal_year_start_date, :on => :update
  validates_date :fiscal_year_end_date, :on => :update
  validates_dates_order :fiscal_year_start_date, :fiscal_year_end_date,
    :message => "Start date must come before End date.", :on => :update
  validate :validates_date_range, :if => Proc.new { |model| model.fiscal_year_start_date.present? }

  ### Callbacks
  after_save :update_cached_currency_amounts
  after_create :create_data_responses
  before_destroy :check_no_requests
  before_destroy :check_no_funder_references
  before_destroy :check_no_implementer_references

  ### Delegates
  delegate :name, :to => :location, :prefix => true, :allow_nil => true # gives you location_name - oh lordy!

  ### Named scopes
  named_scope :without_users, :conditions => 'users_count = 0'
  named_scope :ordered, :order => 'lower(name) ASC, created_at DESC'
  named_scope :with_type, lambda { |type| {:conditions => ["organizations.raw_type = ?", type]} }
  named_scope :reporting, :conditions => ['raw_type not in (?)', NON_REPORTING_TYPES]
  named_scope :nonreporting, :conditions => ['raw_type in (?)', NON_REPORTING_TYPES]
  named_scope :responses_by_states, lambda { |request, states|
    { :joins => {:data_responses => :data_request },
      :conditions => ["data_requests.id = ? AND
                       data_responses.state IN (?)", request.id, states]} }

  ### Class Methods

  def self.with_users
    find(:all, :joins => :users, :order => 'organizations.name ASC').uniq
  end

  def self.merge_organizations!(target, duplicate)
    duplicate.responses.each do |response|
      target_response = target.responses.find(:first,
        :conditions => ["data_request_id = ?", response.data_request_id])
      target_response.projects << response.projects
      ### move Funder references of Duplicate to Target
      target_response.projects.each do |project|
        project.in_flows.each do |in_flow|
          if in_flow.from == duplicate
            in_flow.from = target
            in_flow.save(false)
          end
        end
      end
      target_response.activities << response.activities
    end

    duplicate.move_funder_references!(target)
    duplicate.move_implementer_references!(target)
    target.users << duplicate.users
    duplicate.reload.destroy # reload other organization so that it does not remove the previously assigned data_responses
  end

  def self.download_template(organizations = [])
    FasterCSV.generate do |csv|
      csv << Organization::FILE_UPLOAD_COLUMNS
      if organizations
        organizations.each do |org|
          row = [org.name, org.raw_type, org.fosaid, org.currency]
          csv << row
        end
      end
    end
  end

  def self.create_from_file(doc)
    saved, errors = 0, 0
    doc.each do |row|
      attributes = row.to_hash
      organization = Organization.new(attributes)
      organization.save ? (saved += 1) : (errors += 1)
    end
    return saved, errors
  end

  def self.unstarted_responses(request)
    responses_by_states(request, ['unstarted'])
  end

  def self.started_responses(request)
    responses_by_states(request, ['started'])
  end

  def self.submitted_responses(request)
    responses_by_states(request, ['submitted'])
  end

  def self.rejected_responses(request)
    responses_by_states(request, ['rejected'])
  end

  def self.accepted_responses(request)
    responses_by_states(request, ['accepted'])
  end

  ### Instance Methods

  # Convenience until we deprecate the "data_" prefixes
  def responses
    self.data_responses
  end

  def to_s
    name
  end

  def user_emails(limit = 3)
    self.users.find(:all, :limit => limit).map{|u| u.email}
  end

  # TODO: write spec
  def short_name
    #TODO remove district name in (), capitalized, and as below
    n = name.gsub("| "+ location_name, "") if location
    n ||= name
    tidy_name(n)
  end

  def display_name(length = 100)
    n = self.name || "Unnamed organization"
    n.first(length)
  end

  def funding_chains(request)
    ufs = projects_in_request(request).map{|p| p.funding_chains(false)}.flatten
    if ufs.empty?
      ufs = [FundingChain.new({:organization_chain => [self, self]})]
    end
    ufs
  end

  def funding_chains_to(to, request)
    fs = projects_in_request(request).map{|p| p.funding_chains_to(to)}.flatten
    FundingChain.merge_chains(fs)
  end

  def best_guess_funding_chains_to(to, request)
    chains = funding_chains_to(to, request)
    unless chains.empty?
      chains
    else
      guess_funding_chains_to(to,request)
    end
  end

  def guess_funding_chains_to(to, request)
    if ["Donor", "Bilateral", "Multilateral"].include?(raw_type)
      # assume i funded even if didnt enter it
      return [FundingChain.new({:organization_chain => [self, to]})]
    else
      # evenly split across all funding sources
      chains = funding_chains(request)
      unless chains.empty?
        FundingChain.add_to(chains, to)
      else
        #assume I am self funded if I entered no funding information
        # could enter "Unknown - maybe #{self.name}" ?
        [FundingChain.new({:organization_chain => [self, to]})]
      end
    end
  end

  # returns the last response that was created.
  def latest_response
    self.responses.latest_first.first
  end

  def response_for(request)
    self.responses.find_by_data_request_id(request)
  end

  def response_status(request)
    response_for(request).status
  end

  def reporting?
    !nonreporting?
  end

  def nonreporting?
    NON_REPORTING_TYPES.include?(raw_type)
  end

  def currency
    read_attribute(:currency).blank? ? "USD" : read_attribute(:currency)
  end

  def last_user_logged_in
    users.select{ |a,b| a.last_login_at.present? }.max do |a,b|
      a.last_login_at <=> b.last_login_at
    end
  end

  # last login at will return nil on first login, but current will be set
  def current_user_logged_in
    users.select{ |a,b| a.current_login_at.present? }.max do |a,b|
      a.current_login_at <=> b.current_login_at
    end
  end

  #workaround for authlogic not setting last to current on first login
  def last_or_current_user_logged_in
    last_user_logged_in || current_user_logged_in
  end

  # Merge helper
  def move_funder_references!(target_org)
    self.out_flows.each do |referencing_flow|
      referencing_flow.from = target_org
      referencing_flow.save(false)
    end
  end

  # Merge helper
  def move_implementer_references!(target_org)
    self.implementer_splits.each do |referencing_split|
      referencing_split.organization = target_org
      referencing_split.save(false)
    end
  end

  protected

    def tidy_name(n)
      n = n.gsub("Health Center", "HC")
      n = n.gsub("District Hospital", "DH")
      n = n.gsub("Health Post", "HP")
      n = n.gsub("Dispensary", "Disp")
      n
    end

    def check_no_requests
      unless data_requests.count == 0
        errors.add_to_base "Cannot delete organization with Requests"
        return false
      end
    end

    def check_no_funder_references
      unless out_flows.empty?
        errors.add_to_base "Cannot delete organization with Funder references"
        return false
      end
    end

    def check_no_implementer_references
      unless implementer_splits.empty?
        errors.add_to_base "Cannot delete organization with Implementer references"
        return false
      end
    end

  private
    def update_cached_currency_amounts
      if currency_changed?
        dr_activities.each do |a|
          a.code_assignments.each {|c| c.save}
          a.save
        end

        self.projects.each do |project|
          project.update_cached_currency_amounts
        end
      end
    end

    def validates_date_range
      errors.add(:base, "The end date must be exactly one year after the start date") unless (fiscal_year_start_date + (1.year - 1.day)).eql? fiscal_year_end_date
    end

    def create_data_responses
      if raw_type != 'Non-Reporting'
        DataRequest.all.each do |data_request|
          dr = self.data_responses.find(:first,
                    :conditions => {:data_request_id => data_request.id})
          unless dr
            dr = self.data_responses.new
            dr.data_request = data_request
            dr.save!
          end
        end
      end
    end
end

# == Schema Information
#
# Table name: organizations
#
#  id                               :integer         not null, primary key
#  name                             :string(255)
#  created_at                       :datetime
#  updated_at                       :datetime
#  raw_type                         :string(255)
#  fosaid                           :string(255)
#  users_count                      :integer         default(0)
#  currency                         :string(255)
#  fiscal_year_start_date           :date
#  fiscal_year_end_date             :date
#  contact_name                     :string(255)
#  contact_position                 :string(255)
#  contact_phone_number             :string(255)
#  contact_main_office_phone_number :string(255)
#  contact_office_location          :string(255)
#  location_id                      :integer
#

