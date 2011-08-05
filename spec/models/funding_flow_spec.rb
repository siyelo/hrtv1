require File.dirname(__FILE__) + '/../spec_helper'

describe FundingFlow do
  describe "Attributes" do
    it { should allow_mass_assignment_of(:organization_text) }
    it { should allow_mass_assignment_of(:project_id) }
    it { should allow_mass_assignment_of(:from) }
    it { should allow_mass_assignment_of(:to) }
    it { should allow_mass_assignment_of(:self_provider_flag) }
    it { should allow_mass_assignment_of(:organization_id_from) }
    it { should allow_mass_assignment_of(:organization_id_to) }
    it { should allow_mass_assignment_of(:spend) }
    it { should allow_mass_assignment_of(:spend_q4_prev) }
    it { should allow_mass_assignment_of(:spend_q1) }
    it { should allow_mass_assignment_of(:spend_q2) }
    it { should allow_mass_assignment_of(:spend_q3) }
    it { should allow_mass_assignment_of(:spend_q4) }
    it { should allow_mass_assignment_of(:budget_q4_prev) }
    it { should allow_mass_assignment_of(:budget_q1) }
    it { should allow_mass_assignment_of(:budget_q2) }
    it { should allow_mass_assignment_of(:budget_q3) }
    it { should allow_mass_assignment_of(:budget_q4) }
  end

  describe "Associations" do
    it { should belong_to :from }
    it { should belong_to :to }
    it { should belong_to :project }
  end

  describe "Validations" do
    ### these break with  shoulda 2.11.3 "translation missing"
    #it { should validate_presence_of(:organization_id_to) }
    #it { should validate_presence_of(:organization_id_from) }
    # and this breaks too
    #it { should validate_numericality_of(:organization_id_from) }
    it { should validate_numericality_of(:project_from_id) }
    it { should validate_numericality_of(:budget) }
    it { should validate_numericality_of(:budget_q1) }
    it { should validate_numericality_of(:budget_q2) }
    it { should validate_numericality_of(:budget_q3) }
    it { should validate_numericality_of(:budget_q4) }
    it { should validate_numericality_of(:budget_q4_prev) }
    it { should validate_numericality_of(:spend) }
    it { should validate_numericality_of(:spend_q1) }
    it { should validate_numericality_of(:spend_q2) }
    it { should validate_numericality_of(:spend_q3) }
    it { should validate_numericality_of(:spend_q4) }
    it { should validate_numericality_of(:spend_q4_prev) }
  end

  describe "Callbacks" do
    describe "#set_total_amounts" do
      before :each do
        @organization = Factory(:organization, :currency => 'USD')
        @request      = Factory(:data_request, :organization => @organization)
        @response     = @organization.latest_response
        @project      = Factory(:project, :data_response => @response)
        @organization.reload # reload in_flows
        @project.reload      # reload in_flows
      end

      it "sets budget amount as sum of budget quarters (Q1-Q4)" do
        funding_flow = Factory(:funding_flow, :project => @project,
                               :from => @organization, :to => @organization,
                               :budget => nil, :budget_q4_prev => 5,
                               :budget_q1 => 10, :budget_q2 => 10,
                               :budget_q3 => 10, :budget_q4 => 10)
        funding_flow.budget.should == 40
      end

      it "sets spend amount as sum of spend quarters (Q1-Q4)" do
        funding_flow = Factory(:funding_flow, :project => @project,
                               :from => @organization, :to => @organization,
                               :spend => nil, :spend_q4_prev => 5,
                               :spend_q1 => 10, :spend_q2 => 10,
                               :spend_q3 => 10, :spend_q4 => 10)
        funding_flow.spend.should == 40
      end

      describe "keeping Money amounts in-sync" do
        before :each do
          Money.default_bank.add_rate(:RWF, :USD, 0.002)
          @funding_flow = Factory(:funding_flow, :project => @project,
                                  :from => @organization, :to => @organization,
                                  :spend => 123.45, :budget => 123.45)
        end

        it "should update spend in USD after project currency change" do
          @p = @funding_flow.project
          @p.currency = 'RWF'
          @p.save
          @funding_flow.reload
          @funding_flow.spend_in_usd.should == 0.2469
        end

        it "should update spend in USD after organization currency change" do
          @organization.currency = "RWF"
          @organization.save
          @funding_flow.reload
          @funding_flow.spend_in_usd.should == 0.2469
        end
      end

    end

    describe "#update_cached_usd_amounts" do
      before :each do
        Money.default_bank.add_rate(:RWF, :USD, 0.1)
      end

      context "GOR FY" do
        it "sets budget_in_usd and spend_in_usd amounts" do
          @organization = Factory(:organization, :currency => 'RWF',
                                 :fiscal_year_start_date => "2010-07-01",
                                 :fiscal_year_end_date => "2011-06-30")
          @request      = Factory(:data_request, :organization => @organization)
          @response     = @organization.latest_response
          @project      = Factory(:project, :data_response => @response)
          funding_flow = Factory(:funding_flow, :project => @project,
                                 :from => @organization, :to => @organization,
                                 :budget => 123, :spend => 456)
          funding_flow.budget_in_usd.should == 12.3
          funding_flow.spend_in_usd.should == 45.6
        end
      end

      context "USG FY" do
        it "sets budget_in_usd and spend_in_usd amounts" do
          @organization = Factory(:organization, :currency => 'RWF',
                                 :fiscal_year_start_date => "2010-10-01",
                                 :fiscal_year_end_date => "2011-09-30")
          @request      = Factory(:data_request, :organization => @organization)
          @response     = @organization.latest_response
          @project      = Factory(:project, :data_response => @response)
          funding_flow = Factory(:funding_flow, :project => @project,
                                 :from => @organization, :to => @organization,
                                 :budget_q4_prev => 10, :budget_q1 => 10,
                                 :budget_q2 => 10, :budget_q3 => 10, :budget_q4 => 999,
                                 :spend_q4_prev => 11, :spend_q1 => 11,
                                 :spend_q2 => 11, :spend_q3 => 11, :spend_q4 => 999)
          funding_flow.budget_in_usd.should == 4
          funding_flow.spend_in_usd.should == 4.4
        end
      end
    end
  end

  describe "more validations" do
    before :each do
      basic_setup_project
    end

    it "should validate the spend fields" do
      @funding_flow = Factory.build(:funding_flow,
                                    :project => @project, :spend => 'abcd',
                                    :from => @organization, :to => @organization)
      @funding_flow.save.should be_false
    end

    it "should validate the budget fields" do
      @funding_flow = Factory.build(:funding_flow,
                                    :project => @project, :budget => 'abcd',
                                    :from => @organization, :to => @organization)
      @funding_flow.save.should be_false
    end
  end

  describe "currency" do
    it "returns project currency" do
      basic_setup_project
      @project.currency = "RWF"
      @project.save
      funding_flow = Factory.build(:funding_flow,
                                    :project => @project,
                                    :from => @organization, :to => @organization)
      funding_flow.currency.should == "RWF"
    end
  end

  describe "#name" do
    it "returns from and to organizations in the name" do
      basic_setup_project
      from = Factory.create(:organization, :name => 'Organization 1')
      to   = Factory.create(:organization, :name => 'Organization 2')
      funding_flow = Factory.create(:funding_flow,
                                    :project => @project,
                                    :from => from, :to => to)

      funding_flow.name.should == "From: #{from} - To: #{to}"
    end
  end

  describe "deprecated Response api" do
    it "should return (deprecated) response (but will do so via associated project)" do
      basic_setup_project
      from = Factory.create(:organization, :name => 'Organization 1')
      to   = Factory.create(:organization, :name => 'Organization 2')
      funding_flow = Factory.create(:funding_flow,
                                    :project => @project,
                                    :from => from, :to => to)
      funding_flow.response.should == @response
      funding_flow.data_response.should == @response
    end
  end
end
