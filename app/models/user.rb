class User < ActiveRecord::Base
  acts_as_authentic

  ### Constants
  ROLES = %w[admin reporter activity_manager]
  FILE_UPLOAD_COLUMNS = %w[organization_name username email full_name roles password password_confirmation]

  ### Attributes
  attr_accessible :full_name, :email, :username, :organization_id, :organization,
                  :password, :password_confirmation, :roles, :tips_shown, :organizations

  ### Associations
  has_many :comments
  has_many :data_responses, :through => :organization
  belongs_to :organization, :counter_cache => true
  belongs_to :current_response, :class_name => "DataResponse", :foreign_key => :data_response_id_current
  has_and_belongs_to_many :organizations, :join_table => "organizations_managers" # for activity managers

  ### Validations
  validates_presence_of  :username, :email, :organization_id, :data_response_id_current
  validates_uniqueness_of :email, :username, :case_sensitive => false
  validates_confirmation_of :password, :on => :create
  validates_length_of :password, :within => 8..64, :on => :create

  ### Callbacks
  before_validation :set_current_response, :unless => Proc.new{|m| m.data_response_id_current.present?}

  ### Delegates
  delegate :responses, :to => :organization # instead of deprecated data_response
  delegate :latest_response, :to => :organization # find the last response in the org

  ### Class Methods

  # Used by Authlogic's UserSession to find the user by username or by email
  def self.find_by_username_or_email(login)
    self.find(:first, :conditions => ["username = :login OR email = :login", {:login => login}])
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
    roles = roles.collect {|r| r.to_s} # allows symbols to be passed in
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

  # TODO: spec or remove
  def to_s
    username
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

  # name() will give you their email if their (non-mandatory) full name isn't set
  def name
    full_name.presence || username
  end

  def gravatar(size = 30)
    "http://gravatar.com/avatar/#{Digest::MD5.hexdigest(email.downcase)}.png?s=#{size}&d=mm"
  end

  def current_request
    @current_request ||= self.current_response.request
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

  private

    def role?(role)
      roles.include?(role.to_s)
    end

    def set_current_response
      if organization.present? && organization.data_responses.present?
        self.current_response = organization.data_responses.last
      end
    end
end





# == Schema Information
#
# Table name: users
#
#  id                       :integer         not null, primary key
#  username                 :string(255)
#  email                    :string(255)
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
#  perishable_token         :string(255)     default(""), not null
#  tips_shown               :boolean         default(TRUE)
#

