class User < ActiveRecord::Base
  acts_as_authentic

  ### Constants
  ROLES = %w[admin reporter activity_manager org_admin]
  FILE_UPLOAD_COLUMNS = %w[organization_name email full_name roles]

  ### Attributes
  attr_accessible :full_name, :email, :organization_id, :organization,
                  :password, :password_confirmation, :roles, :tips_shown

  ### Associations
  has_many :comments
  has_many :data_responses, :through => :organization
  belongs_to :organization, :counter_cache => true
  # TODO: remove
  belongs_to :current_data_response, :class_name => "DataResponse",
              :foreign_key => :data_response_id_current

  ### Validations
  validates_presence_of :email, :organization_id, :roles
  validates_uniqueness_of :email, :case_sensitive => false
  validates_confirmation_of :password, :on => :create
  validates_length_of :password, :within => 8..64, :on => :create

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

  def save_and_invite(inviter)
    self.invite_token = generate_token
    self.save(false)
    send_user_invitation(inviter)
  end

  def activate
    if valid?
      self.invite_token = nil
      self.active = true
      self.save
    end
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
    roles = (roles || []).collect {|r| r.to_s} # allows symbols to be passed in
    self.roles_mask = (roles & ROLES).map { |r| 2**ROLES.index(r) }.sum
  end

  def roles
    ROLES.reject { |r| ((roles_mask || 0) & 2**ROLES.index(r)).zero? }
  end

  def admin?
    role?('admin')
  end

  def reporter?
    role?('reporter')
  end

  def activity_manager?
    role?('activity_manager')
  end

  def org_admin?
    role?('org_admin')
  end

  # TODO: spec or remove
  def to_s
    email
  end

  # TODO: spec or remove
  # Law of Demeter methods
  def organization_status
    return "No Organization" if organization.nil?
    current_dr = current_data_response
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

  def only_password_errors?
    errors.length == errors.on(:password).to_a.length +
      errors.on(:password_confirmation).to_a.length
  end

  private

    def role?(role)
      roles.include?(role.to_s)
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
#

