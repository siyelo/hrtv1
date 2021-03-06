class User < ActiveRecord::Base

  acts_as_authentic do |c|
    c.validates_length_of_password_field_options = {:minimum => 6,
      :if => :require_password? }
    c.validates_confirmation_of_password_field_options = {:minimum => 6,
      :if => (password_salt_field ? "#{password_salt_field}_changed?".to_sym : nil)}
    c.validates_length_of_password_confirmation_field_options = {:minimum => 6,
      :if => :require_password?}
  end

  ### Constants
  ROLES = %w[admin reporter activity_manager district_manager]
  FILE_UPLOAD_COLUMNS = %w[organization_name email full_name roles password password_confirmation]

  ### Attributes
  attr_accessible :full_name, :email, :organization_id, :organization,
                  :password, :password_confirmation, :roles, :tips_shown,
                  :organization_ids, :location_id

  ### Associations
  has_many :comments, :dependent => :destroy
  has_many :data_responses, :through => :organization
  belongs_to :organization, :counter_cache => true
  belongs_to :current_response, :class_name => "DataResponse", :foreign_key => :data_response_id_current
  has_and_belongs_to_many :organizations, :join_table => "organizations_managers" # for activity managers
  belongs_to :location

  ### Validations
  # AuthLogic handles email uniqueness validation
  validates_presence_of :full_name, :email, :organization_id
  validates_presence_of :location_id, :message => "can't be blank", :if => Proc.new{ |model| model.roles.include?('district_manager') }
  validate :validate_inclusion_of_roles
  validate :validate_organization

  ### Callbacks
  before_validation :assign_current_response_to_latest, :unless => Proc.new{|m| m.data_response_id_current.present?}
  before_save :unassign_organizations, :if => Proc.new{|m| m.roles.exclude?('activity_manager') }
  before_save :unassign_location, :if => Proc.new{ |m| m.roles.exclude?('district_manager') }

  ### Delegates
  delegate :responses, :to => :organization # instead of deprecated data_response
  delegate :latest_response, :to => :organization # find the last response in the org

  # assign organization association so that counter cache is updated
  def organization_id=(organization_id)
    self.organization = Organization.find_by_id(organization_id) if organization_id.present?
  end

  ### Class Methods

  #authlogic authentication
  def self.find_by_login_or_email(login)
     #find_by_login(login) || find_by_email(login)
     find_by_email(login)
  end

  def self.download_template
    FasterCSV.generate do |csv|
      csv << User::FILE_UPLOAD_COLUMNS
    end
  end

  def self.create_from_file(doc)
    saved, errors = 0, 0
    doc.each do |row|
      attributes = row.to_hash
      organization = Organization.find_by_name(attributes.delete('organization_name'))
      attributes.merge!(:organization_id => organization.id) if organization
      user = User.new(attributes)
      user.save ? (saved += 1) : (errors += 1)
    end
    return saved, errors
  end

  ### Instance Methods

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

  def sysadmin?
    role?('admin')
  end

  def reporter?
    role?('reporter') || sysadmin?
  end

  def district_manager?
    role?('district_manager')
  end

  def activity_manager?
    role?('activity_manager') || sysadmin?
  end

  # TODO: spec or remove
  def to_s
    name_or_email
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

  # name() will give you their email if their full name isn't set
  def name
    full_name.present? ? full_name : email
  end

  def name_or_email
    name || email
  end

  def generate_token
    Digest::SHA1.hexdigest("#{self.email}#{Time.now}")[24..38]
  end

  def activate
    self.active = true
    self.invite_token = nil
    self.save
  end

  def only_password_errors?
    errors.length == errors.on(:password).to_a.length +
      errors.on(:password_confirmation).to_a.length
  end

  def save_and_invite(inviter)
    self.valid? ## We need to call self.valid?
    if only_password_errors?
      self.invite_token = generate_token
      self.save(false)
      send_user_invitation(inviter)
    end
  end

  def send_user_invitation(inviter)
    Notifier.deliver_send_user_invitation(self, inviter)
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
    assign_current_response_to_latest
    self.save(false)
  end

  def current_organization
    @current_organization ||= self.current_response.organization
  end

  def change_current_response!(new_request_id)
    response = responses.find_by_data_request_id(new_request_id)
    if response
      self.current_response = response
      self.save(false)
    end
  end

  # authlogic only updates last_login after youve signed in the 2nd time
  # if the user has only signed in once, return the current login date
  def last_signin_at
    current_login_at
  end

  private

    def assign_current_response_to_latest
      if organization.present? && organization.data_responses.present?
        self.current_response = organization.latest_response
      end
    end

    def role?(role)
      roles.include?(role.to_s)
    end

    def unassign_organizations
      self.organizations = []
    end

    def unassign_location
      self.location_id = nil
    end

    def validate_inclusion_of_roles
      if roles.blank? || roles.detect{|role| ROLES.exclude?(role)}
        errors.add(:roles, "is not included in the list")
      end
    end

    def validate_organization
      if district_manager? && roles.length == 1 && organization.reporting?
        errors.add(:organization_id, 'cannot assign a "reporting" organization to District Manager. Please select organization with raw type "Non-Reporting"')
      end
    end

    # allow user to be created without a password
    # allow user to be updated without a password
    # but dont allow them to go active with an empty password
    def require_password?
      self.active? && (!self.password.blank? || self.crypted_password.nil?)
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
#  invite_token             :string(255)
#  active                   :boolean         default(FALSE)
#  location_id              :integer
#  current_login_at         :datetime
#  last_login_at            :datetime
#

