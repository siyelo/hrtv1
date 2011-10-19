require File.dirname(__FILE__) + '/../spec_helper'

include DelayedJobSpecHelper

describe DataResponse do
  describe "Associations" do
    it { should belong_to(:organization) }
    it { should belong_to(:data_request) }
    it { should have_many(:activities) }
    it { should have_many(:other_costs).dependent(:destroy) }
    it { should have_many(:projects).dependent(:destroy) }
    it { should have_many(:implementer_splits) } # delegate destroy to project -> activity
    it { should have_many(:users_currently_completing) }
    it { should have_many(:comments).dependent(:destroy) }
  end

  describe "Validations" do
    subject { basic_setup_response; @response }
    it { should validate_presence_of(:data_request_id) }
    it { should validate_presence_of(:organization_id) }
    it { should validate_uniqueness_of(:data_request_id).scoped_to(:organization_id) }

    it "cannot assign nil state" do
      basic_setup_response
      @response.state = nil
      @response.valid?.should be_false
    end

    it "cannot assign unexisting state" do
      basic_setup_response
      @response.state = 'invalid'
      @response.valid?
      @response.errors.on(:state).should include('is not included in the list')
    end
  end

  describe "State machine" do
    before :each do
      organization = Factory(:organization)
      request      = Factory(:data_request, :organization => organization)
      @response    = organization.latest_response
    end

    it "sets unstarted as default state" do
      @response.state.should == 'unstarted'
    end

    context "first project is created" do
      it "transitions from unstarted to started when first project is created" do
        @response.state.should == 'unstarted'
        Factory(:project, :data_response => @response)
        @response.state.should == 'started'
      end

      it "does not transitions back to in progress if it's in rejected state" do
        @response.state = 'rejected'
        Factory(:project, :data_response => @response)
        @response.state.should == 'rejected'
      end
    end

    context "first other cost without is created" do
      it "transitions from unstarted to started when first project is created" do
        @response.state.should == 'unstarted'
        Factory(:other_cost, :data_response => @response)
        @response.reload.state.should == 'started'
      end

      it "does not transitions back to in progress if it's in rejected state" do
        @response.state = 'rejected'
        Factory(:other_cost, :data_response => @response)
        @response.state.should == 'rejected'
      end
    end

    context "no other costs without project" do
      context "all projects are destroyed" do
        it "moves the response into unstarted state" do
          @response.state.should == 'unstarted'
          project = Factory(:project, :data_response => @response)
          @response.state.should == 'started'
          project.destroy
          @response.reload.state.should == 'unstarted'
        end
      end
    end

    context "other costs without project present" do
      it "moves the response into unstarted state" do
        @response.state.should == 'unstarted'
        project = Factory(:project, :data_response => @response)
        other_cost = Factory(:other_cost, :data_response => @response)
        @response.state.should == 'started'
        project.destroy
        @response.reload.state.should == 'started'
        other_cost.destroy
        @response.reload.state.should == 'unstarted'
      end
    end

    context "response is submitted and activity is deleted" do
      it "moves the response into started state" do
        @response.state.should == 'unstarted'
        project = Factory(:project, :data_response => @response)
        @response.state.should == 'started'
        activity1 = Factory(:activity, :data_response => @response,
                            :project => project)
        activity2 = Factory(:activity, :data_response => @response,
                            :project => project)
        @response.submit!
        @response.state.should == 'submitted'
        activity1.destroy
        @response.reload.state.should == 'submitted'
        activity2.destroy
        @response.reload.state.should == 'started'
      end
    end

    describe "#submittable?" do
      it "can be submitted when is started" do
        @response.state = 'started'
        @response.submittable?.should be_true
      end

      it "can be submitted when is rejected" do
        @response.state = 'rejected'
        @response.submittable?.should be_true
      end

      it "cannot be submitted when is unstarted" do
        @response.state = 'unstarted'
        @response.submittable?.should be_false
      end

      it "cannot be submitted when is submitted" do
        @response.state = 'submitted'
        @response.submittable?.should be_false
      end

      it "cannot be submitted when is approved" do
        @response.state = 'approved'
        @response.submittable?.should be_false
      end
    end
  end

  describe 'Currency cache update' do
    before :each do
      Money.default_bank.add_rate(:RWF, :USD, 0.5)
      Money.default_bank.add_rate(:EUR, :USD, 1.5)
      @organization = Factory(:organization, :currency => 'RWF')
      @request      = Factory(:data_request, :organization => @organization)
      @response     = @organization.latest_response
      @project      = Factory(:project, :data_response => @response,
                              :currency => nil)
      @activity     = Factory(:activity, :data_response => @response,
                              :project => @project)
      split        = Factory(:implementer_split, :activity => @activity,
                             :budget => 1000, :spend => 2000, :organization => @organization)
      @activity.reload
      @activity.save
    end

    it "should update cached USD amounts on Activity and Code Assignment" do
      @activity.budget_in_usd.should == 500
      @activity.spend_in_usd.should == 1000
      @organization.reload # dr.activities wont be updated otherwise
      @organization.currency = 'EUR'
      @organization.save
      @activity.reload
      @activity.budget_in_usd.should == 1500
      @activity.spend_in_usd.should == 3000
    end
  end

  describe "#name" do
    it "returns data_response name" do
      organization = Factory(:organization)
      request      = Factory(:data_request, :organization => organization,
                             :title => 'Data Request 1')
      response     = organization.latest_response

      response.name.should == 'Data Request 1'
    end
  end

  describe "#budget & #spend" do
    before :each do
      @organization = Factory(:organization, :currency => 'USD')
      request      = Factory(:data_request, :organization => @organization)
      @response    = @organization.latest_response
    end

    context "same currency" do
      it "returns total" do
        project      = Factory(:project, :data_response => @response)
        @activity    = Factory(:activity, :data_response => @response, :project => project)
        split1       = Factory(:implementer_split, :activity => @activity,
                               :budget => 200, :spend => 100, :organization => Factory(:organization))
        @oc1         = Factory(:other_cost, :data_response => @response, :project => project)
        split2       = Factory(:implementer_split, :activity => @activity,
                               :budget => 200, :spend => 100, :organization => Factory(:organization))
        @oc2         = Factory(:other_cost, :data_response => @response)
        split3       = Factory(:implementer_split, :activity => @activity,
                               :budget => 200, :spend => 100, :organization => Factory(:organization))
        @activity.reload; @activity.save;
        @oc1.reload; @oc1.save;
        @oc2.reload; @oc2.save;
        @response.budget.to_f.should == 600
        @response.spend.to_f.should == 300
      end
    end

    context "different currency" do
      it "returns total" do
        Money.default_bank.add_rate(:RWF, :USD, 0.5)
        Money.default_bank.add_rate(:USD, :RWF,  2)
        project      = Factory(:project, :data_response => @response, :currency => 'RWF')
        @activity1   = Factory(:activity, :data_response => @response, :project => project)
        split1        = Factory(:implementer_split, :activity => @activity1,
                               :budget => 200, :spend => 100, :organization => Factory(:organization))
        @other_cost1  = Factory(:other_cost, :data_response => @response, :project => project)
        split2        = Factory(:implementer_split, :activity => @other_cost1,
                               :budget => 200, :spend => 100, :organization => Factory(:organization))
        @other_cost2 = Factory(:other_cost, :data_response => @response)
        split        = Factory(:implementer_split, :activity => @other_cost2,
                               :budget => 200, :spend => 100, :organization => Factory(:organization))
        @activity1.reload; @activity1.save;
        @other_cost1.reload; @other_cost1.save;
        @other_cost2.reload; @other_cost2.save;
        @response.budget.to_f.should == 400 # 100 + 100 + 200
        @response.spend.to_f.should == 200 # 50 + 50 + 100
      end
    end
  end
end
