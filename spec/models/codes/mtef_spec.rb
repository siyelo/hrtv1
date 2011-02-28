require File.dirname(__FILE__) + '/../../spec_helper'

describe Mtef do
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

      Mtef.roots_with_level.should == [[0, mtef.id], [1, nha.id], [2, nsp.id], [3, nasa.id]]
    end

    it "returns codes by level" do
    end
  end

  describe "codes_by_level" do
    it "returns leaves when level is nil set" do
      # first level
      mtef1 = Factory.create(:mtef_code, :short_display => 'mtef1')

      # second level
      nha = Factory.create(:nha_code, :short_display => 'nha')
      nha.move_to_child_of(mtef1)

      mtef11 = Factory.create(:mtef_code, :short_display => 'mtef11')
      mtef11.move_to_child_of(mtef1)

      Mtef.codes_by_level.should == Mtef.leaves
      Mtef.codes_by_level.should == [mtef11]
    end

    it "returns leaves for a level" do
      # first level
      mtef1 = Factory.create(:mtef_code, :short_display => 'mtef1')

      # second level
      nha = Factory.create(:nha_code, :short_display => 'nha')
      nha.move_to_child_of(mtef1)

      mtef11 = Factory.create(:mtef_code, :short_display => 'mtef11')
      mtef11.move_to_child_of(mtef1)

      mtef111 = Factory.create(:mtef_code, :short_display => 'mtef111')
      mtef111.move_to_child_of(mtef11)

      Mtef.codes_by_level(1).should == [mtef11]
      Mtef.codes_by_level(2).should == [mtef111]
    end
  end
end

