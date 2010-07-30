require 'lib/ActAsDataElement'

# == Schema Information
#
# Table name: activities
#
#  id                 :integer         not null, primary key
#  name               :string(255)
#  beneficiary        :string(255)
#  target             :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  comments           :string(255)
#  expected_total     :decimal(, )
#  provider_id        :integer
#  other_cost_type_id :integer
#  description        :text
#  type               :string(255)
#  start_month        :string(255)
#  end_month          :string(255)
#  budget             :decimal(, )
#  spend_q1           :decimal(, )
#  spend_q2           :decimal(, )
#  spend_q3           :decimal(, )
#  spend_q4           :decimal(, )
#
class Activity < ActiveRecord::Base
  acts_as_commentable
  include ActAsDataElement
  configure_act_as_data_element

  before_save :authorize_and_set_owner
  #TODO add current data response but since only 1 atm, dont need
  default_scope :conditions => ["activities.organization_id_owner = ? or 1=?",
    ValueAtRuntime.new(Proc.new{User.current_user.organization.id}),
    ValueAtRuntime.new(Proc.new{User.current_user.role?(:admin) ? 1 : 0})]
  belongs_to :owner, :class_name => "Organization", :foreign_key => "organization_id_owner"

  has_and_belongs_to_many :projects
  has_and_belongs_to_many :indicators
  has_and_belongs_to_many :locations
  has_many :lineItems
  belongs_to :provider, :foreign_key => :provider_id, :class_name => "Organization"

  has_and_belongs_to_many :organizations # organizations targeted by this activity / aided
  has_and_belongs_to_many :beneficiaries # codes representing who benefits from this activity

  # TODO double check these go away from glenn's changes
#  has_many :code_assignments, :foreign_key => :activity_id, :dependent => :destroy
#  has_many :codes, :through => :code_assignments
  has_many :budget_codings, :foreign_key => :activity_id, :dependent => :destroy
  has_many :budget_codes, :through => :budget_codings, :source => :code
  has_many :expenditure_codings, :foreign_key => :activity_id, :dependent => :destroy
  has_many :expenditure_codes, :through => :expenditure_codings, :source => :code

  attr_accessor :budget_amounts
  attr_accessor :expenditure_amounts
  after_save :update_budget_codings
  after_save :update_expenditure_codings

  # delegate :providers, :to => :projects
  def valid_providers
    #TODO use delegates_to
    projects.valid_providers
  end

  def valid_roots_for_code_assignment
    @@valid_root_types = [Mtef, Nha, Nasa, Nsp]
    Code.roots.reject { |r| ! @@valid_root_types.include? r.class }
  end

  private

  # trick to help clean up controller code
  # http://ramblings.gibberishcode.net/archives/rails-has-and-belongs-to-many-habtm-demystified/17
  def update_budget_codings
    if budget_amounts
      budget_codings.delete_all
      budget_amounts.delete_if { |key,val| val["a"].nil? || val["p"].nil? }
      budget_amounts.delete_if { |key,val| val["a"].empty? && val["p"].empty? }
      selected_codes = budget_amounts.nil? ? [] : budget_amounts.keys.collect{ |id| Code.find_by_id(id) }
      selected_codes.each { |code| BudgetCoding.create!( :activity => self,
                                      :code => code,
                                      :amount => currency_to_number(budget_amounts[code.id.to_s]["a"]),
                                      :percentage => budget_amounts[code.id.to_s]["p"] ) unless code.nil? }
    end
  end

  def update_expenditure_codings
    if expenditure_amounts
      expenditure_codings.delete_all
      expenditure_amounts.delete_if { |key,val| val["a"].nil? || val["p"].nil? }
      expenditure_amounts.delete_if { |key,val| val["a"].empty? && val["p"].empty? }
      selected_codes = expenditure_amounts.nil? ? [] : expenditure_amounts.keys.collect{ |id| Code.find_by_id(id) }
      selected_codes.each { |code| ExpenditureCoding.create!( :activity => self,
                                      :code => code,
                                      :amount => currency_to_number(expenditure_amounts[code.id.to_s]["a"]),
                                      :percentage => expenditure_amounts[code.id.to_s]["p"] ) unless code.nil? }
    end
  end


  # assumes a format like "17,798,123.00"
  def currency_to_number(number_string, options ={})
    options.symbolize_keys!
    defaults  = I18n.translate(:'number.format', :locale => options[:locale], :raise => true) rescue {}
    currency  = I18n.translate(:'number.currency.format', :locale => options[:locale], :raise => true) rescue {}
    defaults  = defaults.merge(currency)
    delimiter = options[:delimiter] || defaults[:delimiter]

    number_string.gsub(delimiter,'')
  end

  protected

  def authorize_and_set_owner
    current_user = User.current_user
    # TODO authorize and throw exception if no create/update for you! no soup for you!

    # don't remove the self reference below, otherwise it breaks
    unless current_user.role?(:admin) && self.owner != nil
      self.owner = User.current_user.organization 
    end
  end
end
