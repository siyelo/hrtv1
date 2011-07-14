require 'validators'
class DataRequest < ActiveRecord::Base

  ### Attributes
  attr_accessible :organization_id, :title, :final_review,
                  :start_date, :end_date, :due_date, :budget, :spend,
                  :year_2, :year_3, :year_4, :year_5, :purposes, :locations,
                  :inputs, :budget_by_quarter

  ### Associations
  belongs_to :organization
  has_many :data_responses, :dependent => :destroy

  ### Validations
  validates_presence_of :organization_id, :title
  validates_date :due_date
  validates_date :start_date
  validates_date :end_date
  validates_dates_order :start_date, :end_date, :message => "Start date must come before End date."

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

  def spend_and_budget?
    spend? && budget?
  end

  def only_spend?
    spend? && !budget?
  end

  def only_budget?
    budget? && !spend?
  end

  def no_long_term_budgets?
    !year_2 && !year_3 && !year_4 && !year_5
  end

  def requested_amounts
    r = []
    r << "Expenditure" if spend?
    r << "Budget" if budget?
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
#  start_date        :date
#  end_date          :date
#  budget            :boolean         default(TRUE), not null
#  spend             :boolean         default(TRUE), not null
#  final_review      :boolean         default(FALSE)
#  year_2            :boolean         default(TRUE)
#  year_3            :boolean         default(TRUE)
#  year_4            :boolean         default(TRUE)
#  year_5            :boolean         default(TRUE)
#  purposes          :boolean         default(TRUE)
#  locations         :boolean         default(TRUE)
#  inputs            :boolean         default(TRUE)
#  service_levels    :boolean         default(TRUE)
#  budget_by_quarter :boolean         default(FALSE)
#

