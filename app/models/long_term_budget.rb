class LongTermBudget < ActiveRecord::Base

  ### Associations
  belongs_to :organization
  has_many   :budget_entries, :dependent => :destroy

  ### Validations
  validates_presence_of :organization_id, :year

  def update_budgets(classifications)
    classifications.each_pair do |purpose_id, amounts|
      #raise purpose_id.to_yaml
      raise amounts.to_yaml
      amounts.each_pair do |index, amount|
        budget_entry = budget_entries.find_or_initialize_by_purpose_id_and_year(year + index + 1)
        budget_entry.amount = amount
        budget_entry.save
      end
    end
    raise classifications.to_yaml
    [:year1, :year2, :year3, :year4].each_with_index do |key, index|
      classifications[key].each_pair do |purpose_id, amount|
        budget_entry = budget_entries.find_or_initialize_by_long_term_budget_id_and_purpose_id(id, purpose_id)
        budget_entry.year = year + index + 1
        budget_entry.amount = amount
        budget_entry.save!
      end
    end
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

