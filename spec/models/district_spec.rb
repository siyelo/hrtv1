require File.dirname(__FILE__) + '/../spec_helper'

describe District do
  describe "associations" do
    it { should belong_to(:old_location) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:population) }
  end
end

