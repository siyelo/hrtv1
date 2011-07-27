require 'validators'
class DataRequest < ActiveRecord::Base

  ### Attributes
  attr_accessible :organization_id, :title, :final_review, :due_date, :budget, :spend,
                  :year_2, :year_3, :year_4, :year_5, :purposes, :locations,
                  :inputs, :start_year

  ### Associations
  belongs_to :organization
  has_many :data_responses, :dependent => :destroy

  ### Validations
  validates_presence_of :organization_id, :title
  validates_date :due_date
  validates_inclusion_of :start_year, :in => 1900..2999, :message => 'is not a valid year'

  ### Callbacks
  after_create :create_data_responses

  ### Instance Methods

  def name
    title
  end

  def status
    return 'Final review' if final_review?
    return 'In progress'
  end

  def start_date
    Date.parse("#{self.start_year}-07-01")
  end

  def end_date
    Date.parse("#{self.start_year.to_i+1}-06-30")
  end

  def no_long_term_budgets?
    !year_2 && !year_3 && !year_4 && !year_5
  end

  def requested_amounts
    r = []
    r << "Past Expenditure"
    r << "Current Budget"
    r
  end

  private
    def create_data_responses
      Organization.all.each do |organization|
        dr = organization.data_responses.find(:first,
          :conditions => {:data_request_id => self.id})
        unless dr
          dr = organization.data_responses.new
          dr.data_request = self
          dr.save!
        end
      end
    end
end

# == Schema Information
#
# Table name: data_requests
#
#  id                :integer         not null, primary key
#  organization_id   :integer
#  title             :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  due_date          :date
#  final_review      :boolean         default(FALSE)
#  year_2            :boolean         default(TRUE)
#  year_3            :boolean         default(TRUE)
#  year_4            :boolean         default(TRUE)
#  year_5            :boolean         default(TRUE)
#  purposes          :boolean         default(TRUE)
#  locations         :boolean         default(TRUE)
#  inputs            :boolean         default(TRUE)
#  budget_by_quarter :boolean         default(FALSE)
#  start_year        :integer
#

