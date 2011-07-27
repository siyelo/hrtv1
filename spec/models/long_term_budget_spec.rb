require 'spec_helper'

describe LongTermBudget do
  describe "Associations" do
    it { should belong_to(:organization) }
    it { should have_many(:budget_entries).dependent(:destroy) }
  end

  describe "Validations" do
    it { should validate_presence_of(:organization_id) }
    it { should validate_presence_of(:year) }
  end
end
