require File.dirname(__FILE__) + '/../spec_helper'

describe CodingTree do
  before :each do
    # Visual structure
    #
    #               / code111
    #      / code11 - code112
    # code1
    #      \ code12 - code121
    #               \ code122
    #                   - code1221
    #
    #               / code211
    #      / code21 - code212
    # code2
    #      \ code22 - code221
    #               \ code222
    #                   - code2221

    # first level
    @code1    = Factory.create(:code, :short_display => 'code1')
    @code2    = Factory.create(:code, :short_display => 'code2')

    # second level
    @code11    = Factory.create(:code, :short_display => 'code11')
    @code12    = Factory.create(:code, :short_display => 'code12')
    @code21    = Factory.create(:code, :short_display => 'code21')
    @code22    = Factory.create(:code, :short_display => 'code22')
    @code11.move_to_child_of(@code1)
    @code12.move_to_child_of(@code1)
    @code21.move_to_child_of(@code2)
    @code22.move_to_child_of(@code2)

    # third level
    @code111   = Factory.create(:code, :short_display => 'code111')
    @code112   = Factory.create(:code, :short_display => 'code112')
    @code121   = Factory.create(:code, :short_display => 'code121')
    @code122   = Factory.create(:code, :short_display => 'code122')
    @code211   = Factory.create(:code, :short_display => 'code211')
    @code212   = Factory.create(:code, :short_display => 'code212')
    @code221   = Factory.create(:code, :short_display => 'code221')
    @code222   = Factory.create(:code, :short_display => 'code222')
    @code111.move_to_child_of(@code11)
    @code112.move_to_child_of(@code11)
    @code121.move_to_child_of(@code12)
    @code122.move_to_child_of(@code12)
    @code211.move_to_child_of(@code21)
    @code212.move_to_child_of(@code21)
    @code221.move_to_child_of(@code22)
    @code222.move_to_child_of(@code22)

    # fourth level
    @code1221   = Factory.create(:code, :short_display => 'code1221')
    @code1221.move_to_child_of(@code122)
    @code2221   = Factory.create(:code, :short_display => 'code2221')
    @code2221.move_to_child_of(@code222)

    basic_setup_project
    @activity = Factory.create(:activity, :data_response => @response, :project => @project,
                               :budget => 100, :spend => 200)

  end

  describe "Tree" do
    it "has code associated" do
      ca1 = Factory.create(:coding_budget, :activity => @activity, :code => @code1)
      ct  = CodingTree.new(@activity, CodingBudget)
      ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes
      ct.roots.length.should == 1
      ct.roots[0].code.should == @code1
    end

    it "has code assignment associated" do
      ca1 = Factory.create(:coding_budget, :activity => @activity, :code => @code1)
      ct  = CodingTree.new(@activity, CodingBudget)
      ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes
      ct.roots.length.should == 1
      ct.roots[0].ca.should == ca1
    end

    it "has children associated (children of root)" do
      ca1  = Factory.create(:coding_budget, :activity => @activity, :code => @code1)
      ca11 = Factory.create(:coding_budget, :activity => @activity, :code => @code11)
      ct   = CodingTree.new(@activity, CodingBudget)
      ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes
      ct.roots[0].children.length.should == 1
      ct.roots[0].children.map(&:ca).should == [ca11]
      ct.roots[0].children.map(&:code).should == [@code11]
    end

    it "has children associated (children of a children of a root)" do
      ca1   = Factory.create(:coding_budget, :activity => @activity, :code => @code1)
      ca11  = Factory.create(:coding_budget, :activity => @activity, :code => @code11)
      ca111 = Factory.create(:coding_budget, :activity => @activity, :code => @code111)
      ct    = CodingTree.new(@activity, CodingBudget)
      ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes
      ct.roots[0].children[0].children.length.should == 1
      ct.roots[0].children[0].children.map(&:ca).should == [ca111]
      ct.roots[0].children[0].children.map(&:code).should == [@code111]
    end
  end

  describe "root" do
    it "has roots" do
      ca1 = Factory.create(:coding_budget, :activity => @activity, :code => @code1)
      ca2 = Factory.create(:coding_budget, :activity => @activity, :code => @code2)
      ct  = CodingTree.new(@activity, CodingBudget)
      ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes
      ct.roots.length.should == 2
      ct.roots.map(&:ca).should   == [ca1, ca2]
      ct.roots.map(&:code).should == [@code1, @code2]
    end
  end

  describe "coding tree" do
    it "is valid when activity amount is nil and classifications amount is 0" do
      @activity.budget = nil
      ct  = CodingTree.new(@activity, CodingBudget)
      ct.stub(:root_codes).and_return([@code1]) # stub root_codes
      ct.valid?.should == true
    end

    it "is valid when activity amount is 0 and classifications amount is 0" do
      @activity.budget = nil
      ct  = CodingTree.new(@activity, CodingBudget)
      ca1 = Factory.create(:coding_budget, :activity => @activity, :code => @code1, :cached_amount => 0)
      ct.stub(:root_codes).and_return([@code1]) # stub root_codes
      ct.valid?.should == true
    end

    it "is not valid when activity amount is 0 and classifications amount greater than 0" do
      @activity.budget = nil
      ca1 = Factory.create(:coding_budget, :activity => @activity, :code => @code1, :cached_amount => 40)
      ct  = CodingTree.new(@activity, CodingBudget)
      ct.stub(:root_codes).and_return([@code1]) # stub root_codes
      ct.valid?.should == false
    end

    it "is valid when there are only roots" do
      ca1 = Factory.create(:coding_budget, :activity => @activity, :code => @code1, :cached_amount => 40)
      ca2 = Factory.create(:coding_budget, :activity => @activity, :code => @code2, :cached_amount => 60)
      ct  = CodingTree.new(@activity, CodingBudget)
      ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes
      ct.valid?.should == true
    end

    it "is valid when sum_of_children is same as parent cached_sum (2 level)" do
      ca1  = Factory.create(:coding_budget, :activity => @activity, :code => @code1, :cached_amount => 100, :sum_of_children => 100)
      ca11 = Factory.create(:coding_budget, :activity => @activity, :code => @code11, :cached_amount => 100)
      ct   = CodingTree.new(@activity, CodingBudget)
      ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes
      ct.valid?.should == true
    end

    it "is valid when sum_of_children is same as parent cached_sum (3 level)" do
      ca1   = Factory.create(:coding_budget, :activity => @activity, :code => @code1, :cached_amount => 100, :sum_of_children => 100)
      ca11  = Factory.create(:coding_budget, :activity => @activity, :code => @code11, :cached_amount => 100, :sum_of_children => 100)
      ca111 = Factory.create(:coding_budget, :activity => @activity, :code => @code111, :cached_amount => 100)
      ct    = CodingTree.new(@activity, CodingBudget)
      ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes
      ct.valid?.should == true
    end

    # looks like the amount from a child is only bubbling up 3 levels
    # something happens as moves up from 3 to 4 that it loses amounts
    it "is valid when there is one 4 levels down coding of 100% (4 level)" do
      ca1221 = Factory.create(:coding_budget, :activity => @activity, :code => @code1221, :amount => 100)
      ct    = CodingTree.new(@activity, CodingBudget)
      ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes
      ct.set_cached_amounts!
      ct.valid?.should == true
    end

    it "is valid when root children has lower amount" do
      ca1  = Factory.create(:coding_budget, :activity => @activity, :code => @code1, :cached_amount => 100, :sum_of_children => 99)
      ca11 = Factory.create(:coding_budget, :activity => @activity, :code => @code11, :cached_amount => 99)
      ct   = CodingTree.new(@activity, CodingBudget)
      ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes
      ct.valid?.should == true
    end

    it "is not valid when root children has greated amount" do
      ca1  = Factory.create(:coding_budget, :activity => @activity, :code => @code1, :cached_amount => 100, :sum_of_children => 101)
      ca11 = Factory.create(:coding_budget, :activity => @activity, :code => @code11, :cached_amount => 101)
      ct   = CodingTree.new(@activity, CodingBudget)
      ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes
      ct.valid?.should == false
    end

    it "is valid when root children has no amounts and type is CodingBudgetDistrict" do
      ca1  = Factory.create(:coding_budget_district, :activity => @activity, :code => @code1, :cached_amount => 50, :sum_of_children => 0)
      ca2  = Factory.create(:coding_budget_district, :activity => @activity, :code => @code2, :cached_amount => 50, :sum_of_children => 0)
      ct   = CodingTree.new(@activity, CodingBudgetDistrict)
      ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes
      ct.valid?.should == true
    end

    it "is valid when root children has no amounts and type is CodingSpendDistrict" do
      ca1  = Factory.create(:coding_spend_district, :activity => @activity, :code => @code1, :cached_amount => 100, :sum_of_children => 0)
      ca2  = Factory.create(:coding_spend_district, :activity => @activity, :code => @code2, :cached_amount => 100, :sum_of_children => 0)
      ct   = CodingTree.new(@activity, CodingSpendDistrict)
      ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes
      ct.valid?.should == true
    end
  end

  describe "code assignment" do
    it "all code assignments are valid when coding tree is valid" do
      ca1   = Factory.create(:coding_budget, :activity => @activity, :code => @code1, :cached_amount => 100, :sum_of_children => 100)
      ca11  = Factory.create(:coding_budget, :activity => @activity, :code => @code11, :cached_amount => 100, :sum_of_children => 100)
      ca111 = Factory.create(:coding_budget, :activity => @activity, :code => @code111, :cached_amount => 100)
      ct    = CodingTree.new(@activity, CodingBudget)
      ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes
      ct.valid_ca?(ca1).should == true
      ct.valid_ca?(ca11).should == true
      ct.valid_ca?(ca111).should == true
    end

    it "detects invalid node when coding tree is not valid" do
      ca1  = Factory.create(:coding_budget, :activity => @activity, :code => @code1, :cached_amount => 100, :sum_of_children => 101)
      ca11 = Factory.create(:coding_budget, :activity => @activity, :code => @code11, :cached_amount => 101)
      ct   = CodingTree.new(@activity, CodingBudget)
      ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes
      ct.valid_ca?(ca1).should == false
      ct.valid_ca?(ca11).should == true
    end
  end

  # NOTE: these specs are done with stubing, but they need to be changed
  # to check for real objects once we remove codes seeds from test db
  describe "root_codes" do
    before :each do
      @fake_codes = [mock(:code)]
    end

    context "activity" do
      before :each do
        basic_setup_activity
      end

      it "returns codes for simple activity and 'CodingBudget' type" do
        Code.stub_chain(:purposes, :roots).and_return(@fake_codes)

        ct = CodingTree.new(@activity, CodingBudget)
        ct.root_codes.should == @fake_codes
      end

      it "returns codes for simple activity and 'CodingBudgetCostCategorization' type" do
        CostCategory.stub(:roots).and_return(@fake_codes)

        ct = CodingTree.new(@activity, CodingBudgetCostCategorization)
        ct.root_codes.should == @fake_codes
      end

      it "returns codes for simple activity and 'CodingBudgetDistrict' type" do
        @activity.stub(:locations).and_return(@fake_codes)

        ct = CodingTree.new(@activity, CodingBudgetDistrict)
        ct.root_codes.should == @fake_codes
      end

      it "returns codes for simple activity and 'HsspBudget' type" do
        HsspStratObj.stub(:all).and_return(@fake_codes)
        HsspStratProg.stub(:all).and_return(@fake_codes)

        ct = CodingTree.new(@activity, HsspBudget)
        ct.root_codes.should == @fake_codes.concat(@fake_codes)
      end

      it "returns codes for other cost activity and 'HsspBudget' type" do
        HsspStratObj.stub(:all).and_return(@fake_codes)
        HsspStratProg.stub(:all).and_return(@fake_codes)

        ct = CodingTree.new(@activity, HsspBudget)
        ct.root_codes.should == @fake_codes.concat(@fake_codes)
      end

      it "returns codes for simple activity and 'CodingSpend' type" do
        Code.stub_chain(:purposes, :roots).and_return(@fake_codes)

        ct = CodingTree.new(@activity, CodingSpend)
        ct.root_codes.should == @fake_codes
      end

      it "returns codes for simple activity and 'CodingSpendCostCategorization' type" do
        CostCategory.stub(:roots).and_return(@fake_codes)

        ct = CodingTree.new(@activity, CodingSpendCostCategorization)
        ct.root_codes.should == @fake_codes
      end

      it "returns codes for simple activity and 'CodingSpendDistrict' type" do
        @activity.stub(:locations).and_return(@fake_codes)

        ct = CodingTree.new(@activity, CodingSpendDistrict)
        ct.root_codes.should == @fake_codes
      end

      it "returns codes for simple activity and 'HsspSpend' type" do
        HsspStratObj.stub(:all).and_return(@fake_codes)
        HsspStratProg.stub(:all).and_return(@fake_codes)

        ct       = CodingTree.new(@activity, HsspSpend)
        ct.root_codes.should == @fake_codes.concat(@fake_codes)
      end

      it "returns codes for other cost activity and 'HsspSpend' type" do
        HsspStratObj.stub(:all).and_return(@fake_codes)
        HsspStratProg.stub(:all).and_return(@fake_codes)

        ct = CodingTree.new(@activity, HsspSpend)
        ct.root_codes.should == @fake_codes.concat(@fake_codes)
      end
    end

    context "other cost" do
      before :each do
        basic_setup_other_cost
      end

      it "returns codes for other cost activity and 'CodingBudget' type" do
        OtherCostCode.stub(:roots).and_return(@fake_codes)

        ct = CodingTree.new(@other_cost, CodingBudget)
        ct.root_codes.should == @fake_codes
      end

      it "returns codes for other cost activity and 'CodingBudgetCostCategorization' type" do
        CostCategory.stub(:roots).and_return(@fake_codes)

        ct = CodingTree.new(@other_cost, CodingBudgetCostCategorization)
        ct.root_codes.should == @fake_codes
      end

      it "returns codes for other cost activity and 'CodingBudgetDistrict' type" do
        @other_cost.stub(:locations).and_return(@fake_codes)

        ct = CodingTree.new(@other_cost, CodingBudgetDistrict)
        ct.root_codes.should == @fake_codes
      end

      it "returns codes for other cost activity and 'CodingSpend' type" do
        OtherCostCode.stub(:roots).and_return(@fake_codes)

        ct = CodingTree.new(@other_cost, CodingSpend)
        ct.root_codes.should == @fake_codes
      end

      it "returns codes for other cost activity and 'CodingSpendCostCategorization' type" do
        CostCategory.stub(:roots).and_return(@fake_codes)

        ct = CodingTree.new(@other_cost, CodingSpendCostCategorization)
        ct.root_codes.should == @fake_codes
      end

      it "returns codes for other cost activity and 'CodingSpendDistrict' type" do
        @other_cost.stub(:locations).and_return(@fake_codes)

        ct = CodingTree.new(@other_cost, CodingSpendDistrict)
        ct.root_codes.should == @fake_codes
      end
    end
  end

  describe "set_cached_amounts" do
    context "root code assignment" do
      it "sets cached_amount and sum_of_children for code assignment with amount" do
        Factory.create(:coding_budget, :activity => @activity, :code => @code1,
                       :amount => 10, :cached_amount => nil, :sum_of_children => nil)
        ct = CodingTree.new(@activity, CodingBudget)
        ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes

        ct.set_cached_amounts!
        ct.reload!

        @activity.code_assignments.length.should == 1

        ct.roots[0].ca.cached_amount.should == 10
        ct.roots[0].ca.sum_of_children.should == 0
      end

      it "sets cached_amount and sum_of_children for code assignment with percentage" do
        Factory.create(:coding_budget, :activity => @activity, :code => @code1,
                       :percentage => 20, :cached_amount => nil, :sum_of_children => nil)
        ct = CodingTree.new(@activity, CodingBudget)
        ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes

        ct.set_cached_amounts!
        ct.reload!

        @activity.code_assignments.length.should == 1

        ct.roots[0].ca.cached_amount.should == 20
        ct.roots[0].ca.sum_of_children.should == 0
      end
    end

    context "root and children code assignment" do
      it "sets cached_amount and sum_of_children for 2 level code assignments with amount" do
        Factory.create(:coding_budget, :activity => @activity, :code => @code1,
                       :amount => 10, :cached_amount => nil, :sum_of_children => nil)
        Factory.create(:coding_budget, :activity => @activity, :code => @code11,
                       :amount => 5, :cached_amount => nil, :sum_of_children => nil)
        Factory.create(:coding_budget, :activity => @activity, :code => @code12,
                       :amount => 5, :cached_amount => nil, :sum_of_children => nil)
        ct = CodingTree.new(@activity, CodingBudget)
        ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes

        ct.set_cached_amounts!
        ct.reload!

        @activity.code_assignments.length.should == 3

        ct.roots[0].ca.cached_amount.should == 10
        ct.roots[0].ca.sum_of_children.should == 10

        ct.roots[0].children[0].ca.cached_amount.should == 5
        ct.roots[0].children[0].ca.sum_of_children.should == 0

        ct.roots[0].children[1].ca.cached_amount.should == 5
        ct.roots[0].children[1].ca.sum_of_children.should == 0
      end

      it "sets cached_amount and sum_of_children for 2 level code assignments with percentage" do
        Factory.create(:coding_budget, :activity => @activity, :code => @code1,
                       :percentage => 20, :cached_amount => nil, :sum_of_children => nil)
        Factory.create(:coding_budget, :activity => @activity, :code => @code11,
                       :percentage => 10, :cached_amount => nil, :sum_of_children => nil)
        Factory.create(:coding_budget, :activity => @activity, :code => @code12,
                       :percentage => 10, :cached_amount => nil, :sum_of_children => nil)
        ct = CodingTree.new(@activity, CodingBudget)
        ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes

        ct.set_cached_amounts!
        ct.reload!

        @activity.code_assignments.length.should == 3

        ct.roots[0].ca.cached_amount.should == 20
        ct.roots[0].ca.sum_of_children.should == 20

        ct.roots[0].children[0].ca.cached_amount.should == 10
        ct.roots[0].children[0].ca.sum_of_children.should == 0

        ct.roots[0].children[1].ca.cached_amount.should == 10
        ct.roots[0].children[1].ca.sum_of_children.should == 0
      end
    end

    context "children without root code assignment" do
      it "sets cached_amount and sum_of_children when children has amount" do
        Factory.create(:coding_budget, :activity => @activity, :code => @code11,
                       :amount => 5, :cached_amount => nil, :sum_of_children => nil)
        ct = CodingTree.new(@activity, CodingBudget)
        ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes

        ct.set_cached_amounts!
        ct.reload!

        @activity.code_assignments.length.should == 2

        ct.roots[0].ca.cached_amount.should == 5
        ct.roots[0].ca.sum_of_children.should == 5

        ct.roots[0].children[0].ca.cached_amount.should == 5
        ct.roots[0].children[0].ca.sum_of_children.should == 0
      end

      it "sets cached_amount and sum_of_children when children has percentage" do
        Factory.create(:coding_budget, :activity => @activity, :code => @code11,
                       :percentage => 10, :cached_amount => nil, :sum_of_children => nil)
        ct = CodingTree.new(@activity, CodingBudget)
        ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes

        ct.set_cached_amounts!
        ct.reload!

        @activity.code_assignments.length.should == 2

        ct.roots[0].ca.cached_amount.should == 10
        ct.roots[0].ca.sum_of_children.should == 10

        ct.roots[0].children[0].ca.cached_amount.should == 10
        ct.roots[0].children[0].ca.sum_of_children.should == 0
      end

      it "sets cached_amount and sum_of_children when children has percentage and activity amount is 0" do
        basic_setup_project
        activity = Factory.create(:activity, :data_response => @response, :project => @project,
                                  :budget => 0, :spend => 200)
        Factory.create(:coding_budget, :activity => activity, :code => @code11,
                       :percentage => 10, :cached_amount => nil, :sum_of_children => nil)
        ct = CodingTree.new(activity, CodingBudget)
        ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes

        ct.set_cached_amounts!
        ct.reload!

        activity.code_assignments.length.should == 2

        ct.roots[0].ca.cached_amount.should == 0
        ct.roots[0].ca.sum_of_children.should == 0

        ct.roots[0].children[0].ca.cached_amount.should == 0
        ct.roots[0].children[0].ca.sum_of_children.should == 0
      end
    end
  end

  describe "total" do
    it "should return total for the tree" do
      Factory.create(:coding_budget, :activity => @activity, :code => @code1,
                     :amount => 10, :cached_amount => nil, :sum_of_children => nil)
      Factory.create(:coding_budget, :activity => @activity, :code => @code2,
                     :amount => 10, :cached_amount => nil, :sum_of_children => nil)
      ct = CodingTree.new(@activity, CodingBudget)
      ct.stub(:root_codes).and_return([@code1, @code2]) # stub root_codes

      ct.set_cached_amounts!
      ct.reload!

      ct.total.should == 20
    end
  end

  describe "cached_children" do
    it "returns cached children" do
      ct    = CodingTree.new(@activity, CodingBudget)
      ct.cached_children(@code1).should == [@code11, @code12]
      ct.cached_children(@code2).should == [@code21, @code22]
      ct.cached_children(@code11).should == [@code111, @code112]
      ct.cached_children(@code12).should == [@code121, @code122]
    end
  end
end
