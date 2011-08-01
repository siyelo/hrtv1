class LongTermBudget < ActiveRecord::Base

  ### Constants
  CLASSIFICATION_LEVEL = 4

  # exception for invalid params
  class InvalidParams < StandardError; end

  ### Associations
  belongs_to :organization
  has_many   :budget_entries, :dependent => :destroy

  ### Validations
  validates_presence_of :organization_id, :year
  validates_uniqueness_of :year, :scope => :organization_id

  def update_budget_entries(classifications)
    if classifications.present?
      delete_budget_entries_unsubmitted_purposes(classifications.keys)
      classifications.each_pair do |purpose_id, amounts|
        purpose = Code.find(purpose_id)

        # purpose levels start from 0, 1, 2, 3 = 4 levels
        break if purpose.level >= CLASSIFICATION_LEVEL

        amounts = check_and_update_budget_entry_amounts(amounts)
        amounts.each_pair do |index, amount|
          create_budget_entry_for_index!(index, purpose.id, amount)
        end
      end
    else
      budget_entries.delete_all
    end
  end

  def budget_entries_by_purposes
    budget_entries.find(:all, :order => "codes.short_display ASC",
      :joins => :purpose, :include => :purpose).group_by{|be| be.purpose }
  end

  private
    def delete_budget_entries_unsubmitted_purposes(purpose_ids)
      BudgetEntry.delete_all(["long_term_budget_id = ? AND
                              purpose_id NOT IN (?)", id, purpose_ids])
    end

    def check_and_update_budget_entry_amounts(amounts)
      defaults = HashWithIndifferentAccess.new({:"0" => 0, :"1" => 0, :"2" => 0, :"3" => 0})

      # check if keys are not included in default keys
      raise InvalidParams unless amounts.keys.all?{|k| defaults.keys.include?(k) }

      # merge amounts into defaults
      defaults.merge(amounts)
    end

    def create_budget_entry_for_index!(index, purpose_id, amount)
      budget_entry_year =  year + index.to_i + 1
      budget_entry = budget_entries.
        find_or_initialize_by_purpose_id_and_year(purpose_id, budget_entry_year)
      budget_entry.amount = amount
      budget_entry.save!
    end
end

# == Schema Information
#
# Table name: long_term_budgets
#
#  id              :integer         not null, primary key
#  organization_id :integer
#  year            :integer
#  created_at      :datetime
#  updated_at      :datetime
#

