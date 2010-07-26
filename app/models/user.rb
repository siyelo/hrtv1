class User < ActiveRecord::Base
  acts_as_authentic

  cattr_accessor :current_user

  has_many  :assignments
  belongs_to :organization

  @current_data_response

  validates_presence_of  :username, :email
  validates_uniqueness_of :email, :case_sensitive => false
  validates_confirmation_of :password, :on => :create
  validates_length_of :password, :within => 8..64, :on => :create

  named_scope :with_role, lambda { |role| {:conditions => "roles_mask & #{2**ROLES.index(role.to_s)} > 0 "} }

  ROLES = %w[admin reporter]

  def roles=(roles)
    self.roles_mask = (roles & ROLES).map { |r| 2**ROLES.index(r) }.sum
  end

  def roles
    ROLES.reject { |r| ((roles_mask || 0) & 2**ROLES.index(r)).zero? }
  end

  def role?(role)
    roles.include? role.to_s
  end

  # GR: why is this needed ?
  # GN: was stubbing User.current_user.organization
  def self.organization
    current_user.organization
  end
end

