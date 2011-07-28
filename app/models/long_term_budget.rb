class LongTermBudget < ActiveRecord::Base

  ### Associations
  belongs_to :organization
  has_many   :budget_entries, :dependent => :destroy

  ### Validations
  validates_presence_of :organization_id, :year
  ### TODO: add uniqueness validations

  def update_budgets(classifications)
    classifications.each_pair do |purpose_id, amounts|
      #raise purpose_id.to_yaml
      #raise amounts.to_yaml
      amounts.each_pair do |index, amount|
        budget_entry_year =  year + index.to_i + 1
        budget_entry = budget_entries.
          find_or_initialize_by_purpose_id_and_year(purpose_id, budget_entry_year)
        budget_entry.amount = amount
        budget_entry.save
      end
    end
  end

  def budget_entries_by_purposes
    budget_entries.find(:all, :include => :purpose).group_by{|be| be.purpose }
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

