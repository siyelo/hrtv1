require 'lib/ActAsDataElement'

class Project < ActiveRecord::Base
  acts_as_commentable

<<<<<<< HEAD
=======
  include ActAsDataElement
  configure_act_as_data_element
  
>>>>>>> 8759c7302f088bab26a59ee7174b861470f2ece6
  has_and_belongs_to_many :activities
  has_and_belongs_to_many :locations
  has_many :funding_flows, :dependent => :nullify

<<<<<<< HEAD
  has_many :funding_sources, :through => :funding_flows, :class_name => "Organization", :source => :from
  has_many :providers, :through => :funding_flows, :class_name => "Organization", :source => :to

  validates_presence_of :name

  attr_accessible :name, :description, :spend, :budget, :entire_budget,
    :start_date, :end_date

  after_create :create_helpful_records_for_workflow
=======

>>>>>>> 8759c7302f088bab26a59ee7174b861470f2ece6

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
  def valid_providers
    f=funding_flows.find(:all, :select => "organization_id_to",
      :conditions =>
      ["organization_id_from = ?", Organization.find_by_name("self").id])

    r=f.collect {|f| f.organization_id_to}
    r
  end

  def create_helpful_records_for_workflow 
    my_org = User.current_user.organization
    #TODO pass in the amount attributes and use them on records below
    #attribs = r.attributes.reject {|a| ! FundingFlow.new.attributes.include? a }
    funding_flows.create! :to => my_org
    funding_flows.create! :from => my_org, :to => my_org, :self_provider_flag => 1
  end

end
