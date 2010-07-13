class Project < ActiveRecord::Base
  acts_as_commentable
  has_and_belongs_to_many :activities
  has_and_belongs_to_many :locations

  has_many :funding_flows, :dependent => :nullify

  def to_s
    name
  end

  def valid_providers
    f=funding_flows.find(:all, :select => "organization_id_to", :conditions => ["organization_id_from = ?", 
                       Organization.find_by_name("self").id])
    r=f.collect {|f| f.organization_id_to}
    r
  end
end
