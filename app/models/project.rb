class Project < ActiveRecord::Base
  acts_as_commentable
  has_and_belongs_to_many :activities
  has_and_belongs_to_many :locations

  has_many :funding_flows, :dependent => :nullify

  has_one :data_element, :as => :data_elementable

  def to_s
    name
  end

  def to_label #so text doesn't spill over in nested scaffs
    if to_s.length > 21
      to_s[0,20]+'...'
    else
      to_s
    end
  end

  def valid_providers
    f=funding_flows.find(:all, :select => "organization_id_to",
      :conditions =>
      ["organization_id_from = ?", Organization.find_by_name("self").id])

    r=f.collect {|f| f.organization_id_to}
    r
  end
end
