require 'lib/ActAsDataElement'

class Activity < ActiveRecord::Base
  acts_as_commentable
  include ActAsDataElement
  configure_act_as_data_element
  has_and_belongs_to_many :projects
  has_and_belongs_to_many :indicators
  has_and_belongs_to_many :locations
  has_many :lineItems
  belongs_to :provider, :foreign_key => :provider_id, :class_name => "Organization"

  has_many :code_assignments, :foreign_key => :activity_id, :dependent => :destroy
  has_many :codes, :through => :code_assignments

  attr_accessor :code_assignment_amounts
  after_save :update_code_assignments

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
  def update_code_assignments
    if code_assignment_amounts
      code_assignments.delete_all
      code_assignment_amounts.delete_if { |key,val| val.empty?}
      selected_codes = code_assignment_amounts.nil? ? [] : code_assignment_amounts.keys.collect{ |id| Code.find_by_id(id) }
      selected_codes.each { |code| self.code_assignments << CodeAssignment.new( :activity => self, :code => code, :amount => code_assignment_amounts[code.id.to_s]) }
    end
  end

end
