require 'spec_helper'

describe LongTermBudget do

  def check_budget_entries(budget_entries, yearly_amounts)
    budget_entries.count.should == 4
    yearly_amounts.each_pair do |year, amount|
      budget_entries.detect{|be| be.year == year}.amount.should == amount
    end

    #budget_entries.detect{|be| be.year == 2001}.amount.should == 10
    #budget_entries.detect{|be| be.year == 2002}.amount.should == 20
    #budget_entries.detect{|be| be.year == 2003}.amount.should == 30
    #budget_entries.detect{|be| be.year == 2004}.amount.should == 40
  end

  describe "Associations" do
    it { should belong_to(:organization) }
    it { should have_many(:budget_entries).dependent(:destroy) }
  end

  describe "Validations" do
    it { should validate_presence_of(:organization_id) }
    it { should validate_presence_of(:year) }
  end

  describe "#update_budget_entries" do
    context "when budget entries does not exist" do
      before :each do
        @long_term_budget = Factory(:long_term_budget, :year => 2000)
        @purpose          = Factory(:mtef_code)
      end

      context "when all amounts for next 4 years are submited" do
        it "creates budget entries for the next 4 years" do
          classifications = { @purpose.id => { "0" => "10",
                                               "1" => "20",
                                               "2" => "30",
                                               "3" => "40" } }
          @long_term_budget.update_budget_entries(classifications)
          budget_entries = @long_term_budget.budget_entries
          check_budget_entries(budget_entries, {2001 => 10, 2002 => 20, 2003 => 30, 2004 => 40})
        end
      end

      context "when only year 1 amount is submited" do
        it "creates budget entries for all next 4 years with zero values, except year 1" do
          classifications = { @purpose.id => { "0" => "10" } }
          @long_term_budget.update_budget_entries(classifications)
          budget_entries = @long_term_budget.budget_entries
          check_budget_entries(budget_entries, {2001 => 10, 2002 => 0, 2003 => 0, 2004 => 0})
        end
      end

      context "when only year 2 amount is submited" do
        it "creates budget entries for all next 4 years with zero values, except year 2" do
          classifications = { @purpose.id => { "1" => "20" } }
          @long_term_budget.update_budget_entries(classifications)
          budget_entries = @long_term_budget.budget_entries
          check_budget_entries(budget_entries, {2001 => 0, 2002 => 20, 2003 => 0, 2004 => 0})
        end
      end

      context "when only year 3 amount is submited" do
        it "creates budget entries for all next 4 years with zero values, except year 3" do
          classifications = { @purpose.id => { "2" => "30" } }
          @long_term_budget.update_budget_entries(classifications)
          budget_entries = @long_term_budget.budget_entries
          check_budget_entries(budget_entries, {2001 => 0, 2002 => 0, 2003 => 30, 2004 => 0})
        end
      end

      context "when only year 4 amount is submited" do
        it "creates budget entries for all next 4 years with zero values, except year 4" do
          classifications = { @purpose.id => { "3" => "40" } }
          @long_term_budget.update_budget_entries(classifications)
          budget_entries = @long_term_budget.budget_entries
          check_budget_entries(budget_entries, {2001 => 0, 2002 => 0, 2003 => 0, 2004 => 40})
        end
      end

      it "raises an exception when invalid params submited (when id not in 0..3)" do
        classifications = { @purpose.id => { "5" => "50" } }
        lambda { @long_term_budget.update_budget_entries(classifications)
               }.should raise_exception(LongTermBudget::InvalidParams)
      end
    end

    context "when budget entries exist" do
      before :each do
        @long_term_budget = Factory(:long_term_budget, :year => 2000)
        @purpose          = Factory(:mtef_code)
        Factory(:budget_entry, :long_term_budget => @long_term_budget,
                :year => 2001, :amount => 10, :purpose => @purpose)
        Factory(:budget_entry, :long_term_budget => @long_term_budget,
                :year => 2002, :amount => 20, :purpose => @purpose)
        Factory(:budget_entry, :long_term_budget => @long_term_budget,
                :year => 2003, :amount => 30, :purpose => @purpose)
        Factory(:budget_entry, :long_term_budget => @long_term_budget,
                :year => 2004, :amount => 40, :purpose => @purpose)
        @long_term_budget.budget_entries.count.should == 4
      end

      context "when submiting nil classifications" do
        it "removes existing budget entries" do
          @long_term_budget.update_budget_entries(nil)
          @long_term_budget.budget_entries.count.should == 0
        end
      end

      context "when submiting empty hash classifications" do
        it "removes existing budget entries" do
          @long_term_budget.update_budget_entries({})
          @long_term_budget.budget_entries.count.should == 0
        end
      end

      context "when submiting an existing classification" do
        it "updated existing budget entries" do
          # check previous state
          budget_entries = @long_term_budget.budget_entries
          check_budget_entries(budget_entries, {2001 => 10, 2002 => 20, 2003 => 30, 2004 => 40})

          # update and check updates are saved
          classifications = { @purpose.id => { "0" => "11",
                                               "1" => "22",
                                               "2" => "33",
                                               "3" => "44" } }
          @long_term_budget.update_budget_entries(classifications)
          budget_entries = @long_term_budget.budget_entries.reload
          check_budget_entries(budget_entries, {2001 => 11, 2002 => 22, 2003 => 33, 2004 => 44})
        end
      end

      context "when not submiting an existing classification" do
        it "removes the not submited budget entries" do
          # first create budget entries for other purpose
          @purpose2 = Factory(:mtef_code)
          Factory(:budget_entry, :long_term_budget => @long_term_budget,
                  :year => 2001, :amount => 10, :purpose => @purpose2)
          Factory(:budget_entry, :long_term_budget => @long_term_budget,
                  :year => 2002, :amount => 20, :purpose => @purpose2)
          Factory(:budget_entry, :long_term_budget => @long_term_budget,
                  :year => 2003, :amount => 30, :purpose => @purpose2)
          Factory(:budget_entry, :long_term_budget => @long_term_budget,
                  :year => 2004, :amount => 40, :purpose => @purpose2)
          @long_term_budget.budget_entries.count.should == 8

          # update and check the deleted budget entries are removed
          classifications = { @purpose.id => { "0" => "11",
                                               "1" => "22",
                                               "2" => "33",
                                               "3" => "44" } }
          @long_term_budget.update_budget_entries(classifications)
          budget_entries = @long_term_budget.budget_entries.reload
          check_budget_entries(budget_entries, {2001 => 11, 2002 => 22, 2003 => 33, 2004 => 44})
        end
      end
    end
  end
end
