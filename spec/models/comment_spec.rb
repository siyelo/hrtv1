require File.dirname(__FILE__) + '/../spec_helper'

describe Comment do
  describe "attributes" do
    it { should allow_mass_assignment_of(:comment) }
    it { should allow_mass_assignment_of(:parent_id) }
    it { should_not allow_mass_assignment_of(:user_id) }
    it { should_not allow_mass_assignment_of(:commentable_id) }
    it { should_not allow_mass_assignment_of(:commentable_type) }
  end

  describe "validations" do
    it { should validate_presence_of :comment }
    it { should validate_presence_of :user_id }
    it { should validate_presence_of :commentable_id }
    it { should validate_presence_of :commentable_type }
  end

  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:commentable) }
  end
end

# == Schema Information
#
# Table name: comments
#
#  id               :integer         primary key
#  comment          :text            default("")
#  commentable_id   :integer
#  commentable_type :string(255)
#  user_id          :integer
#  created_at       :timestamp
#  updated_at       :timestamp
#

