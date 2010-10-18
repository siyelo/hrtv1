# Define removed model BudgetCoding
class BudgetCoding < CodeAssignment
  validates_uniqueness_of :code_id, :scope => :activity_id
end

# Define removed model ExpenditureCoding
class ExpenditureCoding < CodeAssignment
  validates_uniqueness_of :code_id, :scope => :activity_id
end

# Define Activity model with removed methods and associations
class Activity < ActiveRecord::Base
  VALID_ROOT_TYPES = %w[Mtef Nha Nasa Nsp]

  has_and_belongs_to_many :locations
  has_many :budget_codings, :foreign_key => :activity_id, :dependent => :destroy
  has_many :budget_codes, :through => :budget_codings, :source => :code
  has_many :expenditure_codings, :foreign_key => :activity_id, :dependent => :destroy
  has_many :expenditure_codes, :through => :expenditure_codings, :source => :code

  def get_current_assignments(coding_type, code_ids)
    case coding_type
    when 'budget_codes', 'budget_district_codes', 'budget_cost_categories'
      budget_codings.with_code_ids(code_ids).all
    when 'expenditure_codes', 'expenditure_district_codes', 'expenditure_cost_categories'
      expenditure_codings.with_code_ids(code_ids).all
    end
  end

  def get_all_code_ids(coding_type)
    case coding_type
    when 'budget_codes', 'expenditure_codes'
      if self.class.to_s == "OtherCost"
        OtherCostCode.all.map(&:id)
      else
        Code.for_activities.map(&:id)
      end
    when 'budget_district_codes', 'expenditure_district_codes'
      locations.map(&:id)
    when 'budget_cost_categories', 'expenditure_cost_categories'
      CostCategory.all.map(&:id)
    end
  end
end

class AddNewTypesOfCodeAssignments < ActiveRecord::Migration

  def self.up
    puts "Migrating assignments \n"

    Activity.all.each do |activity|
      puts "Migrating... activity #{activity.id}"
      rename_codings(activity, 'budget_codes', 'CodingBudget')
      rename_codings(activity, 'budget_district_codes', 'CodingBudgetDistrict')
      rename_codings(activity, 'budget_cost_categories', 'CodingBudgetCostCategorization')
      rename_codings(activity, 'expenditure_codes', 'CodingExpenditure')
      rename_codings(activity, 'expenditure_district_codes', 'CodingExpenditureDistrict')
      rename_codings(activity, 'expenditure_cost_categories', 'CodingExpenditureCostCategorization')
    end
  end

  def self.down
  end

  private
  def self.rename_codings(activity, coding_type, new_coding_type)
    code_assignments = activity.get_current_assignments(coding_type, activity.get_all_code_ids(coding_type))
    code_assignments.each do |ca|
      ca.type = new_coding_type
      ca.save(false)
    end
  end
end
