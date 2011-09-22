require File.dirname(__FILE__) + '/../spec_helper'

describe FundingFlow do
  describe "Attributes" do
    it { should allow_mass_assignment_of(:organization_text) }
    it { should allow_mass_assignment_of(:project_id) }
    it { should allow_mass_assignment_of(:from) }
    it { should allow_mass_assignment_of(:self_provider_flag) }
    it { should allow_mass_assignment_of(:organization_id_from) }
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
    it { should belong_to :project }
    it { should belong_to :project_from }
  end

  describe "Validations" do
    ### these break with shoulda 2.11.3 "translation missing"
    #it { should validate_presence_of(:organization_id_from) }
    # and this breaks too
    #it { should validate_numericality_of(:organization_id_from) }
    it { should validate_numericality_of(:project_from_id) }
    it { should validate_numericality_of(:budget) }
    it { should validate_numericality_of(:spend) }
  end

  describe "Validations that require a record" do
    before{ basic_setup_funding_flow }
    subject { @funding_flow }
    it { should validate_uniqueness_of(:organization_id_from).scoped_to(:project_id) }
  end

  describe "Custom validations" do
    before :each do
      @donor        = Factory(:organization)
      @organization = Factory(:organization)
      @request      = Factory(:data_request, :organization => @organization)
      @response     = @organization.latest_response
      @project      = Factory(:project, :data_response => @response)
    end

    it "should validate Expenditure and/or Budget is present if nil" do
      @funding_flow = Factory.build(:funding_flow, :project => @project,
                              :from => @donor, :budget => nil, :spend => nil)
      @funding_flow.save.should == false
      @funding_flow.errors.on(:spend).should include(' and/or Planned must be present')
    end

    it "should validate Expenditure and/or Budget is present if blank" do
      @funding_flow = Factory.build(:funding_flow, :project => @project,
                              :from => @donor, :budget => "", :spend => "")
      @funding_flow.save.should == false
      @funding_flow.errors.on(:spend).should include(' and/or Planned must be present')
    end

    it "should validate one OR the other" do
       @funding_flow = Factory.build(:funding_flow, :project => @project,
                               :from => @donor, :budget => "", :spend => "123.00")
       @funding_flow.save.should == true
     end
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

      describe "keeping Money amounts in-sync" do
        before :each do
          Money.default_bank.add_rate(:RWF, :USD, 0.002)
          @project.in_flows = [Factory.build(:funding_flow, :from => @organization, :spend => 123.45,
                                :budget => 123.45)]
          @project.save!
          @funding_flow = @project.in_flows.first
        end

        it "should update spend in USD after project currency change" do
          @p = @funding_flow.project
          @p.currency = 'RWF'; @p.save
          @funding_flow.reload
          @funding_flow.spend_in_usd.to_f.should == 0.2469
        end

        it "should update spend in USD after organization currency change" do
          @organization.currency = "RWF"; @organization.save!
          @funding_flow.reload
          @funding_flow.spend_in_usd.to_f.should == 0.2469
        end
      end
    end

    describe "#update_cached_usd_amounts" do
      before :all do
        Money.default_bank.add_rate(:RWF, :USD, 0.1)
      end

      context "GOR FY" do
        it "sets budget_in_usd and spend_in_usd amounts" do
          @organization  = Factory(:organization, :currency => 'RWF',
                                  :fiscal_year_start_date => "2010-07-01",
                                  :fiscal_year_end_date => "2011-06-30")
          @request       = Factory(:data_request, :organization => @organization)
          @response      = @organization.latest_response
          @project       = Factory(:project, :data_response => @response)
          in_flow        = @project.in_flows.first
          in_flow.budget = 123
          in_flow.spend  = 456
          in_flow.save!
          in_flow.budget_in_usd.should == 12.3
          in_flow.spend_in_usd.should == 45.6
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
                                    :from => @organization)
      @funding_flow.save.should be_false
    end

    it "should validate the budget fields" do
      @funding_flow = Factory.build(:funding_flow,
                                    :project => @project, :budget => 'abcd',
                                    :from => @organization)
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
                                    :from => @organization)
      funding_flow.currency.should == "RWF"
    end
  end

  describe "#name" do
    it "returns from and to organizations in the name" do
      @organization = Factory(:organization, :name => 'Organization 2')
      @other_org    = Factory(:organization, :name => 'ORG2')
      @request      = Factory(:data_request, :organization => @organization)
      @response     = @organization.latest_response
      @project      = Factory(:project, :data_response => @response)
      @project.save!

      from = Factory(:organization, :name => 'Organization 1')
      funding_flow = Factory(:funding_flow, :project => @project, :from => from)
      funding_flow.name.should == "From: #{from} - To: #{@organization}"
    end
  end

  describe "deprecated Response api" do
    it "should return (deprecated) response (but will do so via associated project)" do
      basic_setup_project
      from = Factory.create(:organization, :name => 'Organization 1')
      to   = Factory.create(:organization, :name => 'Organization 2')
      funding_flow = Factory.create(:funding_flow, :project => @project, :from => from)
      funding_flow.response.should == @response
      funding_flow.data_response.should == @response
    end
  end
end
