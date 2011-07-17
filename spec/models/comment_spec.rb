require File.dirname(__FILE__) + '/../spec_helper'

describe Comment do
  describe "Attributes" do
    it { should allow_mass_assignment_of(:comment) }
    it { should allow_mass_assignment_of(:parent_id) }
    it { should_not allow_mass_assignment_of(:user_id) }
    it { should_not allow_mass_assignment_of(:commentable_id) }
    it { should_not allow_mass_assignment_of(:commentable_type) }
  end

  describe "Associations" do
    it { should belong_to(:user) }
    it { should belong_to(:commentable) }
  end

  describe "Validations" do
    it { should validate_presence_of :comment }
    it { should validate_presence_of :user_id }
    it { should validate_presence_of :commentable_id }
    it { should validate_presence_of :commentable_type }
  end

  describe "notifications" do
    before :each do
      organization1 = Factory(:organization, :name => "Requester")
      organization2 = Factory(:organization, :name => "Responder")
      @admin        = Factory(:reporter, :organization => organization1)
      @reporter1    = Factory(:reporter, :organization => organization2,
                              :email => 'reporter1@hrt.com')
      @reporter2    = Factory(:reporter, :organization => organization2,
                              :email => 'reporter2@hrt.com')
      request       = Factory(:data_request, :organization => organization1)
      response      = organization2.latest_response
      @project      = Factory(:project, :data_response => response)
    end

    context "root comment (without parent_id)" do
      it "notifies all reporters in organization" do
        reset_mailer
        Factory(:comment, :commentable => @project, :user => @reporter1)
        unread_emails_for(@admin.email).size.should == 0
        unread_emails_for(@reporter1.email).size.should == 0
        unread_emails_for(@reporter2.email).size.should == 1
      end
    end

    context "reply comment (with parent_id)" do
      it "notifies all users in the thread" do
        # when reporter1 comments, reporter2 receives an email
        reset_mailer
        comment1 = Factory(:comment, :commentable => @project,
                           :user => @reporter1)
        unread_emails_for(@reporter1.email).size.should == 0
        unread_emails_for(@reporter2.email).size.should == 1
        unread_emails_for(@admin.email).size.should == 0

        # when reporter1 comments again, noone receives an email
        reset_mailer
        Factory(:comment, :commentable => @project,
                :user => @reporter1, :parent => comment1)
        unread_emails_for(@reporter1.email).size.should == 0
        unread_emails_for(@reporter2.email).size.should == 0
        unread_emails_for(@admin.email).size.should == 0

        # when reporter2 responds, reporter1 receives an email
        reset_mailer
        Factory(:comment, :commentable => @project,
                :user => @reporter2, :parent => comment1)
        unread_emails_for(@reporter1.email).size.should == 1
        unread_emails_for(@reporter2.email).size.should == 0
        unread_emails_for(@admin.email).size.should == 0
      end
    end
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

