require 'spec_helper'

describe Output do
  describe "Validations" do
    it { should validate_presence_of :description }
  end

  describe "Associations" do
    it { should belong_to :activity }
  end
end
