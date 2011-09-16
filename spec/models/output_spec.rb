require 'spec_helper'

describe Output do
  describe "Validations" do
    it { should validate_presence_of :description }
    it { should ensure_length_of(:description).is_at_most(250) }
  end

  describe "Associations" do
    it { should belong_to :activity }
  end
end
