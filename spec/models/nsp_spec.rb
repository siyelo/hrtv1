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
end

