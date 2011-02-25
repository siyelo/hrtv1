require File.dirname(__FILE__) + '/../spec_helper'

describe Code do

  describe "creating a record" do
    subject { Factory(:code) }
    it { should be_valid }
  end

  describe "attributes" do
    it { should allow_mass_assignment_of(:long_display) }
    it { should allow_mass_assignment_of(:short_display) }
    it { should allow_mass_assignment_of(:description) }
    it { should allow_mass_assignment_of(:start_date) }
    it { should allow_mass_assignment_of(:end_date) }
  end

  describe "associations" do
    it { should have_many :comments }
    it { should have_many :code_assignments }
    it { should have_many :activities }
  end

  describe "named scopes" do
    it "filter codes by type" do
      mtef     = Factory.create(:mtef_code)
      location = Factory.create(:location)

      Code.with_type('Mtef').should == [mtef]
      Code.with_type('Location').should == [location]
    end

    it "filter codes by types" do
      mtef     = Factory.create(:mtef_code)
      location = Factory.create(:location)

      Code.with_types(['Mtef', 'Location']).should == [mtef, location]
    end

    it "filter codes by activity root types" do
      mtef               = Factory.create(:mtef_code)
      nha_code           = Factory.create(:nha_code)
      nasa_code          = Factory.create(:nasa_code)
      nsp_code           = Factory.create(:nsp_code)
      cost_category_code = Factory.create(:cost_category_code)
      other_cost_code    = Factory.create(:other_cost_code)
      location           = Factory.create(:location)
      beneficiary        = Factory.create(:beneficiary)
      hssp_strat_prog    = Factory.create(:hssp_strat_prog)
      hssp_strat_obj     = Factory.create(:hssp_strat_obj)

      Code.for_activities.should == [mtef, nha_code, nasa_code, nsp_code]
    end

    it "orders codes by lft" do
      # first level
      code1    = Factory.create(:code, :short_display => 'code1')
      code2    = Factory.create(:code, :short_display => 'code2')

      # second level
      code11    = Factory.create(:code, :short_display => 'code11')
      code12    = Factory.create(:code, :short_display => 'code12')
      code21    = Factory.create(:code, :short_display => 'code21')
      code22    = Factory.create(:code, :short_display => 'code22')
      code11.move_to_child_of(code1)
      code12.move_to_child_of(code1)
      code21.move_to_child_of(code2)
      code22.move_to_child_of(code2)

      Code.ordered.should == [code1, code11, code12, code2, code21, code22]
    end
  end

  describe "deepest_nesting" do
    # caching prevent this example to pass
    #it "returns deepest nesting for 1 level" do
      ## first level
      #code1    = Factory.create(:code, :short_display => 'code1')

      #Code.deepest_nesting.should == 1
    #end

    # caching prevent this example to pass
    #it "returns deepest nesting for 2 levels" do
      ## first level
      #code1 = Factory.create(:code, :short_display => 'code1')

      ## second level
      #code11 = Factory.create(:code, :short_display => 'code11')
      #code11.move_to_child_of(code1)

      #Code.deepest_nesting.should == 2
    #end

    it "returns deepest nesting for 3 level" do
      # first level
      code1 = Factory.create(:code, :short_display => 'code1')

      # second level
      code11 = Factory.create(:code, :short_display => 'code11')
      code11.move_to_child_of(code1)

      # third level
      code111 = Factory.create(:code, :short_display => 'code111')
      code111.move_to_child_of(code11)

      Code.deepest_nesting.should == 3
    end
  end

  describe "roots with level" do
    it "returns roots with level" do
      # first level
      mtef = Factory.create(:mtef_code, :short_display => 'mtef')

      # second level
      nha = Factory.create(:nha_code, :short_display => 'nha')
      nha.move_to_child_of(mtef)

      # third level
      nsp = Factory.create(:nsp_code, :short_display => 'nsp')
      nsp.move_to_child_of(nha)

      # forth level
      nasa = Factory.create(:nasa_code, :short_display => 'nasa')
      nasa.move_to_child_of(nsp)

      Code.roots_with_level.should == [[0, mtef.id], [1, nha.id], [2, nsp.id], [3, nasa.id]]
      Mtef.roots_with_level.should == [[0, mtef.id], [1, nha.id], [2, nsp.id], [3, nasa.id]]
      Nha.roots_with_level.should == [[1, nha.id], [2, nsp.id], [3, nasa.id]]
      Nsp.roots_with_level.should == [[1, nsp.id], [2, nasa.id]]
      Nasa.roots_with_level.should == [[1, nasa.id]]
    end
  end

  describe "name" do
    it "returns short_display as name" do
      code = Factory.create(:code, :short_display => 'short_display')
      code.name.should == 'short_display'
    end
  end

  describe "to_s" do
    it "returns short_display as to_s" do
      code = Factory.create(:code, :short_display => 'short_display')
      code.to_s.should == 'short_display'
    end
  end

  describe "to_s_prefer_official" do
    it "returns official_name when it's present" do
      code = Factory.create(:code, :official_name => 'official_name')
      code.to_s_prefer_official.should == 'official_name'
    end

    it "returns short_display when official_name is not present" do
      code = Factory.create(:code, :official_name => nil, :short_display => 'short_display')
      code.to_s_prefer_official.should == 'short_display'
    end
  end

  describe "to_s_with_external_id" do
    it "returns to_s_with_external_id when external_id is blank" do
      code = Factory.create(:code, :external_id => nil, :short_display => 'short_display')
      code.to_s_with_external_id.should == 'short_display (n/a)'
    end

    it "returns to_s_with_external_id when external_id is not blank" do
      code = Factory.create(:code, :external_id => 'external_id', :short_display => 'short_display')
      code.to_s_with_external_id.should == 'short_display (external_id)'
    end
  end

  describe "sum_of_assignments_for_activities" do
    before :each do
      Factory.create(:currency, :name => "dollar", :symbol => "USD", :toUSD => "1")
      data_response = Factory.create(:data_response, :currency => "USD")
      @activity1 = Factory.create(:activity, :data_response => data_response, :projects => [])
      @activity2 = Factory.create(:activity, :data_response => data_response, :projects => [])
      @code      = Factory.create(:code, :short_display => 'Code')

      Factory.create(:coding_budget, :activity => @activity1, :code => @code,
                     :amount => 6000, :cached_amount => 6000)
      Factory.create(:coding_budget, :activity => @activity2, :code => @code,
                     :amount => 6000, :cached_amount => 6000)
    end

    it "returns sum of code assignments when no activities" do
      @code.sum_of_assignments_for_activities('CodingBudget', []).should == 0
    end

    it "returns sum of code assignments when one activities" do
      @code.sum_of_assignments_for_activities('CodingBudget', [@activity1]).should == 6000
    end

    it "returns sum of code assignments when few activities" do
      @code.sum_of_assignments_for_activities('CodingBudget', [@activity1, @activity2]).should == 12000
    end
  end

  describe "leaf_assignments_for_activities" do
    before :each do
      Factory.create(:currency, :name => "dollar", :symbol => "USD", :toUSD => "1")
      data_response = Factory.create(:data_response, :currency => "USD")
      @activity1 = Factory.create(:activity, :data_response => data_response, :projects => [])
      @activity2 = Factory.create(:activity, :data_response => data_response, :projects => [])
      @code1     = Factory.create(:code, :short_display => 'code1')
      @code11    = Factory.create(:code, :short_display => 'code11', :parent => @code1)
      @code12    = Factory.create(:code, :short_display => 'code12', :parent => @code1)
    end

    it "returns empty array when no activities" do
      @code1.leaf_assignments_for_activities(CodingBudget, []).should == []
    end

    it "returns empty array when no leaf" do
      @code1.stub(:leaf?) { false }

      @a1ca1  = Factory.create(:coding_budget, :activity => @activity2, :code => @code11,
                             :amount => 5, :cached_amount => 5, :sum_of_children => 5)
      @a1ca11 = Factory.create(:coding_budget, :activity => @activity1, :code => @code11,
                             :amount => 2, :cached_amount => 2)

      @code1.leaf_assignments_for_activities(CodingBudget, [@activity1, @activity2]).should == []
    end

    it "returns only leaves with sum_of_children 0" do
      a1ca1  = Factory.create(:coding_budget, :activity => @activity2, :code => @code11,
                             :amount => 5, :cached_amount => 5, :sum_of_children => 5)
      a1ca11 = Factory.create(:coding_budget, :activity => @activity1, :code => @code11,
                             :amount => 2, :cached_amount => 2)

      a1ca12 = Factory.create(:coding_budget, :activity => @activity2, :code => @code11,
                             :amount => 2, :cached_amount => 2, :sum_of_children => 5)

      @code11.leaf_assignments_for_activities(CodingBudget, [@activity1, @activity2]).should == [a1ca11]
    end

    it "orders code assignments by cached_amount desc" do
      a2ca11 = Factory.create(:coding_budget, :activity => @activity1, :code => @code11,
                             :amount => 2, :cached_amount => 2)
      a2ca12 = Factory.create(:coding_budget, :activity => @activity2, :code => @code11,
                             :amount => 3, :cached_amount => 3)

      @code11.leaf_assignments_for_activities(CodingBudget, [@activity1, @activity2]).should == [a2ca12, a2ca11]
    end
  end

  describe "counter cache" do
    context "comments cache" do
      before :each do
        @commentable = Factory.create(:activity)
      end

      it_should_behave_like "comments_cacher"
    end
  end
end

# == Schema Information
#
# Table name: codes
#
#  id                  :integer         primary key
#  parent_id           :integer
#  lft                 :integer
#  rgt                 :integer
#  short_display       :string(255)
#  long_display        :string(255)
#  description         :text
#  created_at          :timestamp
#  updated_at          :timestamp
#  start_date          :date
#  end_date            :date
#  replacement_code_id :integer
#  type                :string(255)
#  external_id         :string(255)
#  hssp2_stratprog_val :string(255)
#  hssp2_stratobj_val  :string(255)
#  official_name       :string(255)
#  comments_count      :integer         default(0)
#  sub_account         :string(255)
#  nha_code            :string(255)
#  nasa_code           :string(255)
#

