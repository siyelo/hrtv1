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
    #
    #               / code211
    #      / code21 - code212
    # code2
    #      \ code22 - code221
    #               \ code222

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
    @code212.move_to_child_of(@code22)
    @code221.move_to_child_of(@code22)
    @code222.move_to_child_of(@code22)

    @activity = Factory.create(:activity)

    # stub available_codes
    CodingBudget.should_receive(:available_codes).and_return([@code1, @code2])
  end

  context "coding tree" do
    it "has roots" do
      ca1 = Factory.create(:coding_budget, :activity => @activity, :code => @code1)
      ca2 = Factory.create(:coding_budget, :activity => @activity, :code => @code2)
      ct  = CodingTree.new(@activity, CodingBudget)
      ct.roots.length.should == 2
      ct.roots.map(&:ca).should   == [ca1, ca2]
      ct.roots.map(&:code).should == [@code1, @code2]
    end
  end

  context "tree node" do
    it "has code associated" do
      ca1 = Factory.create(:coding_budget, :activity => @activity, :code => @code1)
      ct  = CodingTree.new(@activity, CodingBudget)
      ct.roots.length.should == 1
      ct.roots[0].code.should == @code1
    end

    it "has code assignment associated" do
      ca1 = Factory.create(:coding_budget, :activity => @activity, :code => @code1)
      ct  = CodingTree.new(@activity, CodingBudget)
      ct.roots.length.should == 1
      ct.roots[0].ca.should == ca1
    end

    it "has children associated (children of root)" do
      ca1  = Factory.create(:coding_budget, :activity => @activity, :code => @code1)
      ca11 = Factory.create(:coding_budget, :activity => @activity, :code => @code11)
      ct   = CodingTree.new(@activity, CodingBudget)
      ct.roots[0].children.length.should == 1
      ct.roots[0].children.map(&:ca).should == [ca11]
      ct.roots[0].children.map(&:code).should == [@code11]
    end

    it "has children associated (children of a children of a root)" do
      ca1   = Factory.create(:coding_budget, :activity => @activity, :code => @code1)
      ca11  = Factory.create(:coding_budget, :activity => @activity, :code => @code11)
      ca111 = Factory.create(:coding_budget, :activity => @activity, :code => @code111)
      ct    = CodingTree.new(@activity, CodingBudget)
      ct.roots[0].children[0].children.length.should == 1
      ct.roots[0].children[0].children.map(&:ca).should == [ca111]
      ct.roots[0].children[0].children.map(&:code).should == [@code111]
    end
  end
end

