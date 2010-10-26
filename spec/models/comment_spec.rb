require File.dirname(__FILE__) + '/../spec_helper'

describe Comment do
  describe "associations" do
    it { should belong_to(:user) }
    it { should belong_to(:commentable) }
  end

  describe "validations" do
    it { should validate_presence_of :title }
    it { should validate_presence_of :comment }
    it { should validate_presence_of :user_id }
    it { should validate_presence_of :commentable_type }
    it { should validate_presence_of :commentable_id }
  end
end
