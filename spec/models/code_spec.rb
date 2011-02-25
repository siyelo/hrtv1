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
    it "returns deepest nesting for 1 level" do
      # first level
      code1    = Factory.create(:code, :short_display => 'code1')

      Code.deepest_nesting.should == 1
    end

    it "returns deepest nesting for 2 levels" do
      # first level
      code1 = Factory.create(:code, :short_display => 'code1')

      # second level
      code11 = Factory.create(:code, :short_display => 'code11')
      code11.move_to_child_of(code1)

      Code.deepest_nesting.should == 2
    end

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

