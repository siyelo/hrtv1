require 'spec_helper'

describe BudgetEntry do
  describe "Associations" do
    it { should belong_to(:long_term_budget) }
    it { should belong_to(:purpose) }
  end

  describe "Validations" do
    it { should validate_presence_of(:long_term_budget_id) }
    it { should validate_presence_of(:purpose_id) }
    it { should validate_presence_of(:year) }
  end
end
