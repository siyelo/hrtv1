# == Schema Information
#
# Table name: projects
#
#  id                    :integer         not null, primary key
#  name                  :string(255)
#  description           :text
#  start_date            :date
#  end_date              :date
#  created_at            :datetime
#  updated_at            :datetime
#  budget                :decimal(, )
#  spend                 :decimal(, )
#  entire_budget         :decimal(, )
#  organization_id_owner :integer
#

require 'lib/ActAsDataElement'
require 'lib/acts_as_stripper' #TODO move

class Project < ActiveRecord::Base
  acts_as_commentable

  include ActAsDataElement
  configure_act_as_data_element

  acts_as_stripper

  before_save :authorize_and_set_owner
  default_scope :conditions => ["projects.organization_id_owner = ? or 1=?",
    ValueAtRuntime.new(Proc.new{User.current_user.organization.id}),
    ValueAtRuntime.new(Proc.new{User.current_user.role?(:admin) ? 1 : 0})]
  belongs_to :owner, :class_name => "Organization", :foreign_key => "organization_id_owner"

  has_and_belongs_to_many :activities
  has_and_belongs_to_many :locations
  has_many :funding_flows #, :dependent => :nullify

  has_many :funding_sources, :through => :funding_flows, :class_name => "Organization", :source => :from
  has_many :providers, :through => :funding_flows, :class_name => "Organization", :source => :to

  validates_presence_of :name

  attr_accessible :name, :description, :spend, :budget, :entire_budget,
    :start_date, :end_date

  after_create :create_helpful_records_for_workflow

  def spend=(amount)
    super(strip_non_decimal(amount))
  end

  def budget=(amount)
    super(strip_non_decimal(amount))
  end

  def entire_budget=(amount)
    super(strip_non_decimal(amount))
  end

  def to_s
    result = ''
    result = name unless name.nil?
    result
  end

  # TODO... GR: this is view code - must be moved out of the model
  def to_label #so text doesn't spill over in nested scaffs.
    if to_s.length > 21
      to_s[0,20]+'...'
    else
      to_s
    end
  end

  # this is an AS helper, and currently only seems to be used by activity scaffold.
  # todo - test this - then refactor
  # GN: looks like this isn't being used at all for now
  # let's take it out soon when we have more test coverage
  def valid_providers
    f=funding_flows.find(:all, :select => "organization_id_to",
      :conditions =>
      ["organization_id_from = ?", current_user.organization.id])

    r=f.collect {|f| f.organization_id_to}
    r
  end

  def create_helpful_records_for_workflow
    my_org = User.current_user.organization
    #TODO pass in the amount attributes and use them on records below
    #attribs = r.attributes.reject {|a| ! FundingFlow.new.attributes.include? a }
    funding_flows.create! :to => my_org
    funding_flows.create! :from => my_org, :to => my_org, :self_provider_flag => 1
    activities << OtherCost.new
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
