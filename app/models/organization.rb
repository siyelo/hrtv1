require 'validation_disabler'
require 'validators'
class Organization < ActiveRecord::Base

  ### Constants
  FILE_UPLOAD_COLUMNS = %w[name raw_type fosaid]

  ORGANIZATION_TYPES = ["Bilateral", "Central Govt Revenue", "Clinic/Cabinet Medical", "Communal FOSA", "Dispensary", "District",
     "District Hospital", "Government", "Govt Insurance", "Health Center", "Health Post", "International NGO",
     "Local NGO", "MOH central", "Military Hospital", "MoH unit", "Multilateral", "National Hospital",
     "Other ministries", "Parastatal", "Prison Clinic", "RBC institutions"]

  def usg_fiscal_year
    year = Date.today.strftime('%Y').to_i
    { :start => Date.parse("01-01-#{year}"),
      :end => Date.parse("31-12-#{year}") }
  end

  def gor_fiscal_year
    year = Date.today.strftime('%Y').to_i
    { :start => Date.parse("01-07-#{year - 1}"),
      :end => Date.parse("30-06-#{year}") }
  end

  include ActsAsDateChecker

  ### Attributes
  attr_accessible :name, :raw_type, :fosaid, :currency, :fiscal_year_end_date,
    :fiscal_year_start_date, :contact_name, :contact_position, :contact_phone_number,
    :contact_main_office_phone_number, :contact_office_location

  ### Associations
  has_and_belongs_to_many :activities # activities that target / aid this org
  has_and_belongs_to_many :locations
  has_many :users # people in this organization
  has_and_belongs_to_many :managers, :join_table => "organizations_managers", :class_name => "User" # activity managers

  has_many :data_requests
  has_many :data_responses, :dependent => :destroy
  has_many :dr_activities, :through => :data_responses, :source => :activities
  # TODO: rename organization_id_from -> from_id, organization_id_to -> to_id
  has_many :out_flows, :class_name => "FundingFlow", :foreign_key => "organization_id_from", :dependent => :destroy
  has_many :in_flows, :class_name => "FundingFlow", :foreign_key => "organization_id_to", :dependent => :destroy
  has_many :donor_for, :through => :out_flows, :source => :project
  has_many :implementor_for, :through => :in_flows, :source => :project
  has_many :provider_for, :class_name => "Activity", :foreign_key => :provider_id
  has_many :projects, :through => :data_responses

  ### Validations
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :currency, :contact_name, :contact_position,
                        :contact_office_location, :contact_phone_number,
                        :contact_main_office_phone_number, :on => :update
  validates_inclusion_of :currency, :in => Money::Currency::TABLE.map{|k, v| "#{k.to_s.upcase}"}
  validates_date :fiscal_year_start_date, :on => :update
  validates_date :fiscal_year_end_date, :on => :update
  validates_dates_order :fiscal_year_start_date, :fiscal_year_end_date,
    :message => "Start date must come before End date.", :on => :update
  validate :validates_date_range, :if => Proc.new { |model| model.fiscal_year_start_date.present? }

  ### Callbacks
  after_save :update_cached_currency_amounts
  after_create :create_data_responses

  ### Named scopes
  named_scope :without_users, :conditions => 'users_count = 0'
  named_scope :ordered, :order => 'lower(name) ASC, created_at DESC'
  # works only on postgres
  #named_scope :with_users, :joins => :users, :select => 'DISTINCT ON (organizations.id) *'

  def self.with_users
    find(:all, :joins => :users, :order => 'organizations.name ASC').uniq
  end

  ### Class Methods

  def self.merge_organizations!(target, duplicate)
    ActiveRecord::Base.disable_validation!
    target.activities << duplicate.activities
    target.data_requests << duplicate.data_requests
    target.data_responses << duplicate.data_responses
    target.out_flows << duplicate.out_flows
    target.in_flows << duplicate.in_flows
    target.provider_for << duplicate.provider_for
    target.locations << duplicate.locations
    target.users << duplicate.users
    duplicate.reload.destroy # reload other organization so that it does not remove the previously assigned data_responses
    ActiveRecord::Base.enable_validation!
  end

  def self.download_template
    FasterCSV.generate do |csv|
      csv << Organization::FILE_UPLOAD_COLUMNS
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

  ### Instance Methods

  def is_empty?
    if users.empty? && in_flows.empty? && out_flows.empty? && provider_for.empty? && locations.empty? && activities.empty? && data_responses.select{|dr| dr.empty?}.length == data_responses.size
      true
    else
      false
    end
  end

  def referenced?
    if in_flows.empty? && out_flows.empty? && provider_for.empty? && activities.empty? && data_responses.select{|dr| dr.empty?}.length == data_responses.size
      false
    else
      true
    end
  end

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
    n = name.gsub("| "+locations.first.to_s, "") unless locations.empty?
    n ||= name
    tidy_name(n)
  end

  def display_name(length = 100)
    n = self.name || "<no name>"
    n.first(length)
  end

  def has_provider?(organization)
    projects.map(&:activities).flatten.map(&:provider).include?(organization)
  end

  def projects_in_request(request)
      r = data_responses.select{|dr| dr.data_request = request}.first
      unless r.nil?
        r.projects
      else
        []
      end
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

  def budget_quarters_months(quarter)
    case quarter
    when "q1"
      "#{(gor_fiscal_year[:start] + 12.months).strftime('%b \'%y')} - #{(gor_fiscal_year[:start] + 14.months).strftime('%b \'%y')}"
    when "q2"
      "#{(gor_fiscal_year[:start] + 15.months).strftime('%b \'%y')} - #{(gor_fiscal_year[:start] + 17.months).strftime('%b \'%y')}"
    when "q3"
      "#{(gor_fiscal_year[:start] + 18.months).strftime('%b \'%y')} - #{(gor_fiscal_year[:start] + 20.months).strftime('%b \'%y')}"
    when "q4"
      "#{(gor_fiscal_year[:start] + 21.months).strftime('%b \'%y')} - #{(gor_fiscal_year[:start] + 23.months).strftime('%b \'%y')}"
    when "q1_next_fy"
      "#{(gor_fiscal_year[:start] + 24.months).strftime('%b \'%y')} - #{(gor_fiscal_year[:start] + 26.months).strftime('%b \'%y')}"
    end
  end

  def spend_quarters_months(quarter)
    case quarter
    when "q1"
      "#{gor_fiscal_year[:start].strftime('%b \'%y')} - #{(gor_fiscal_year[:start] + 2.months).strftime('%b \'%y')}"
    when "q2"
      "#{(gor_fiscal_year[:start] + 3.months).strftime('%b \'%y')} - #{(gor_fiscal_year[:start] + 5.months).strftime('%b \'%y')}"
    when "q3"
      "#{(gor_fiscal_year[:start] + 6.months).strftime('%b \'%y')} - #{(gor_fiscal_year[:start] + 8.months).strftime('%b \'%y')}"
    when "q4"
      "#{(gor_fiscal_year[:start] + 9.months).strftime('%b \'%y')} - #{(gor_fiscal_year[:start] + 11.months).strftime('%b \'%y')}"
    when "q1_next_fy"
      "#{(gor_fiscal_year[:start] + 12.months).strftime('%b \'%y')} - #{(gor_fiscal_year[:start] + 14.months).strftime('%b \'%y')}"
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

  protected

    def tidy_name(n)
      n = n.gsub("Health Center", "HC")
      n = n.gsub("District Hospital", "DH")
      n = n.gsub("Health Post", "HP")
      n = n.gsub("Dispensary", "Disp")
      n
    end

  private
    def update_cached_currency_amounts
      if self.currency_changed?
        self.dr_activities.each do |a|
          a.code_assignments.each {|c| c.save}
          a.save
        end
      end
    end

    def validates_date_range
      errors.add(:base, "The end date must be exactly one year after the start date") unless (fiscal_year_start_date + (1.year - 1.day)).eql? fiscal_year_end_date
    end

    def create_data_responses
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









# == Schema Information
#
# Table name: organizations
#
#  id                               :integer         not null, primary key
#  name                             :string(255)
#  old_type                         :string(255)
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
#

