require File.dirname(__FILE__) + '/../spec_helper'

describe Nsp do
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

      Nsp.roots_with_level.should == [[1, nsp.id], [2, nasa.id]]
    end
  end

  describe "leaves" do
    it "returns only Nsp codes which children are not Nsp codes" do
      # first level
      mtef = Factory.create(:mtef_code, :short_display => 'mtef')

      # second level
      nha = Factory.create(:nha_code, :short_display => 'nha')
      nha.move_to_child_of(mtef)

      # third level
      nsp1 = Factory.create(:nsp_code, :short_display => 'nsp1')
      nsp2 = Factory.create(:nsp_code, :short_display => 'nsp2')
      nsp1.move_to_child_of(nha)
      nsp2.move_to_child_of(nha)

      # forth level
      nasa1 = Factory.create(:nasa_code, :short_display => 'nasa1')
      nsp3  = Factory.create(:nsp_code, :short_display => 'nsp3')
      nasa1.move_to_child_of(nsp1)
      nsp3.move_to_child_of(nsp2)


      Nsp.leaves.should == [nsp1, nsp3]
    end
  end

  describe "self_and_nsp_ancestors" do
    it "returns only Nsp codes" do
      # first level
      mtef = Factory.create(:mtef_code, :short_display => 'mtef')

      # second level
      nsp = Factory.create(:nsp_code, :short_display => 'nsp')
      nsp.move_to_child_of(mtef)

      # third level
      nsp2 = Factory.create(:nsp_code, :short_display => 'nsp2')
      nsp2.move_to_child_of(nsp)

      # forth level
      nasa = Factory.create(:nasa_code, :short_display => 'nasa')
      nasa.move_to_child_of(nsp2)

      nsp2.reload.self_and_nsp_ancestors.should == [nsp.reload, nsp2.reload]
    end
  end
end

