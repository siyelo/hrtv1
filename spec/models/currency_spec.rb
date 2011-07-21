require File.dirname(__FILE__) + '/../spec_helper'

describe Currency do
  describe "Validations" do
     it { should validate_uniqueness_of(:description) }
   end
  
end