class User < ActiveRecord::Base

  acts_as_authentic do |c|
    c.validates_length_of_password_field_options = {:minimum => 6,
      :if => :require_password? }
    c.validates_confirmation_of_password_field_options = {:minimum => 6,
      :if => (password_salt_field ? "#{password_salt_field}_changed?".to_sym : nil)}
    c.validates_length_of_password_confirmation_field_options = {:minimum => 6,
      :if => :require_password? }
  end

  ### Constants
  ROLES = %w[admin reporter activity_manager manager] # the ordering is important.
                                                      # Add only to the end.
  FILE_UPLOAD_COLUMNS = %w[organization_name email full_name roles]

  ### Attributes
  attr_accessible :full_name, :email, :organization_id, :organization,
                  :password, :password_confirmation, :roles, :tips_shown,
                  :organizations, :organization_ids, :active

  ### Associations
  has_many :comments
  has_many :data_responses, :through => :organization
  belongs_to :organization, :counter_cache => true
  belongs_to :current_response, :class_name => "DataResponse", :foreign_key => :data_response_id_current
  has_and_belongs_to_many :organizations, :join_table => "organizations_managers" # for activity managers

  ### Validations
  validates_presence_of  :full_name, :email, :organization_id
  validates_uniqueness_of :email, :case_sensitive => false
  validates_confirmation_of :password, :on => :create
  validate :validate_inclusion_of_roles

  ### Callbacks
  before_save :set_current_response, :unless => Proc.new{|m| m.data_response_id_current.present?}
  before_save :unassign_organizations, :if => Proc.new{|m| m.roles.exclude?('activity_manager') }

  ### Delegates
  delegate :responses, :to => :organization # instead of deprecated data_response
  delegate :latest_response, :to => :organization # find the last response in the org

  ### Class Methods

  def self.download_template
    FasterCSV.generate do |csv|
      csv << User::FILE_UPLOAD_COLUMNS
    end
  end

  def self.create_from_file(doc, inviter)
    saved, errors = 0, 0
    doc.each do |row|
      attributes = row.to_hash
      organization = Organization.find_by_name(attributes["organization_name"])
      if organization
        attributes.merge!(:organization_id => organization.id)
      else
        org = Organization.create!(:name => attributes["organization_name"])
      end
      user = User.new(attributes)
      if user.only_password_errors?
        user.save_and_invite(inviter)
        saved += 1
      elsif user.save
        user.save
        saved +=1
      else
        errors += 1
      end
    end
    return saved, errors
  end

  def invite(inviter)
    self.invite_token = generate_token
    self.save
    send_user_invitation(inviter)
  end

  #deprecated in favour of invite()
  def save_and_invite(inviter)
    self.invite_token = generate_token
    self.save(false)
    send_user_invitation(inviter)
  end

  def activate
    self.active = true
    self.invite_token = nil
    return self.save
  end

  def generate_token
    Digest::SHA1.hexdigest("#{self.email}#{Time.now}")[24..38]
  end

  def send_user_invitation(inviter)
    Notifier.deliver_send_user_invitation(self, inviter)
  end

  def deliver_password_reset_instructions!
    reset_perishable_token!
    Notifier.deliver_password_reset_instructions(self)
  end

  def roles=(roles)
    new_roles = roles.collect {|r| r.to_s} # allows symbols to be passed in
    self.roles_mask = (new_roles & ROLES).map { |r| 2**ROLES.index(r) }.sum
  end

  def roles
    @roles || ROLES.reject { |r| ((roles_mask || 0) & 2**ROLES.index(r)).zero? }
  end

  # deprecated - use sysadmin?
  def admin?
    sysadmin?
  end

  def sysadmin?
    role?('admin')
  end

  # deprecated - use sysadmin?
  def admin?
    sysadmin?
  end

  def reporter?
    role?('reporter') || manager? || sysadmin?
  end

  def activity_manager?
    role?('activity_manager') || sysadmin?
  end

  # deprecated
  def org_admin?
    manager?
  end

  def manager?
    role?('manager')  || sysadmin?
  end

  # TODO: spec or remove
  def to_s
    email
  end

  # TODO: spec or remove
  # Law of Demeter methods
  def organization_status
    return "No Organization" if organization.nil?
    current_dr = current_response
    current_dr ||= organization.data_responses.first
    return "No Data Response" if current_dr.nil?
    current_dr.status
  end

  def name
    full_name.present? ? full_name : email
  end

  def name_or_email
    name || email
  end

  def gravatar(size = 30)
    "http://gravatar.com/avatar/#{Digest::MD5.hexdigest(email.downcase)}.png?s=#{size}&d=mm"
  end

  def current_request
    @current_request ||= self.current_response.nil? ? nil : self.current_response.request
  end

  def current_request_name
    @current_request_name ||= self.current_request.name
  end

  # deprecated - use current_response instead
  def current_data_response
    self.current_response
  end

  def current_response_is_latest?
    self.current_response == self.latest_response
  end

  def set_current_response_to_latest!
    self.current_response = self.latest_response
    self.save!
  end

  def current_organization
    @current_organization ||= self.current_response.organization
  end


  def only_password_errors?
    errors.length == errors.on(:password).to_a.length +
      errors.on(:password_confirmation).to_a.length
  end

  private

    def role?(role)
      roles.include?(role.to_s)
    end

    def set_current_response
      if organization.present? && organization.data_responses.present?
        self.current_response = organization.data_responses.last
      end
    end

    def unassign_organizations
      self.organizations = []
    end

    def validate_inclusion_of_roles
      if roles.blank? || roles.detect{|role| ROLES.exclude?(role)}
        errors.add(:roles, "is not included in the list")
      end
    end

    def require_password?
      self.active? && self.crypted_password.blank?
    end
end



# == Schema Information
#
# Table name: users
#
#  id                       :integer         not null, primary key
#  email                    :string(255)     indexed
#  crypted_password         :string(255)
#  password_salt            :string(255)
#  persistence_token        :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#  roles_mask               :integer
#  organization_id          :integer
#  data_response_id_current :integer
#  text_for_organization    :text
#  full_name                :string(255)
#  perishable_token         :string(255)     default(""), not null, indexed
#  tips_shown               :boolean         default(TRUE)
#  active                   :boolean         default(FALSE)
#  invite_token             :string(255)
#

