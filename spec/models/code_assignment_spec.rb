require File.dirname(__FILE__) + '/../spec_helper'

describe CodeAssignment do
  describe "Validations" do
    it { should validate_presence_of :activity_id }
    it { should validate_presence_of :code_id }
  end

  describe "Associations" do
    it { should belong_to :activity }
    it { should belong_to :code }
  end

  describe "Attributes" do
    it { should allow_mass_assignment_of(:activity) }
    it { should allow_mass_assignment_of(:code) }
    it { should allow_mass_assignment_of(:amount) }
    it { should allow_mass_assignment_of(:percentage) }
    it { should allow_mass_assignment_of(:sum_of_children) }
    it { should allow_mass_assignment_of(:cached_amount) }
    it { should allow_mass_assignment_of(:cached_amount_in_usd) }

    it { should allow_value(12345).for(:amount) }
    it { should allow_value(12345.00).for(:amount) }
    it { should allow_value(12345.123).for(:amount) }
    it { should allow_value("12345").for(:amount) }
    it { should allow_value("12345.00").for(:amount) }
    it { should allow_value("12345.123").for(:amount) }
    it { should allow_value("$12345").for(:amount) }
    it { should allow_value("$12345.00").for(:amount) }
    it { should allow_value("$12345.123").for(:amount) }
  end

  describe "named scopes" do
    it "with_code_id" do
      basic_setup_project
      activity = Factory.create(:activity, :data_response => @response, :project => @project,
                                :budget => 100, :spend => 200)

      code1    = Factory.create(:code, :short_display => 'code1')
      code2    = Factory.create(:code, :short_display => 'code2')

      ca1      = Factory.create(:coding_budget, :activity => activity, :code => code1)
      ca2      = Factory.create(:coding_budget, :activity => activity, :code => code2)

      CodeAssignment.with_code_id(code1.id).should == [ca1]
    end

    it "with_code_ids" do
      basic_setup_project
      activity = Factory.create(:activity, :data_response => @response, :project => @project,
                                :budget => 100, :spend => 200)

      code1    = Factory.create(:code, :short_display => 'code1')
      code2    = Factory.create(:code, :short_display => 'code2')
      code11   = Factory.create(:code, :short_display => 'code11')
      code21   = Factory.create(:code, :short_display => 'code21')

      ca1      = Factory.create(:coding_budget, :activity => activity, :code => code1)
      ca2      = Factory.create(:coding_budget, :activity => activity, :code => code2)
      ca11     = Factory.create(:coding_budget, :activity => activity, :code => code11)
      ca21     = Factory.create(:coding_budget, :activity => activity, :code => code21)

      CodeAssignment.with_code_ids([code1.id, code21.id]).should == [ca1, ca21]
    end

    it "with_activity" do
      basic_setup_project
      activity1 = Factory.create(:activity, :data_response => @response, :project => @project,
                                :budget => 100, :spend => 200)
      activity2 = Factory.create(:activity, :data_response => @response, :project => @project,
                                :budget => 100, :spend => 200)

      code      = Factory.create(:code, :short_display => 'code1')

      ca1       = Factory.create(:coding_budget, :activity => activity1, :code => code)
      ca2       = Factory.create(:coding_budget, :activity => activity2, :code => code)

      CodeAssignment.with_activity(activity1.id).should == [ca1]
    end

    it "with_activities" do
      basic_setup_project
      activity1 = Factory.create(:activity, :data_response => @response, :project => @project,
                                :budget => 100, :spend => 200)
      activity2 = Factory.create(:activity, :data_response => @response, :project => @project,
                                :budget => 100, :spend => 200)
      activity3 = Factory.create(:activity, :data_response => @response, :project => @project,
                                :budget => 100, :spend => 200)

      code      = Factory.create(:code, :short_display => 'code1')

      ca1       = Factory.create(:coding_budget, :activity => activity1, :code => code)
      ca2       = Factory.create(:coding_budget, :activity => activity2, :code => code)
      ca3       = Factory.create(:coding_budget, :activity => activity3, :code => code)

      CodeAssignment.with_activities([activity1.id, activity3.id]).should == [ca1, ca3]
    end

    it "with_type" do
      basic_setup_project
      activity = Factory.create(:activity, :data_response => @response, :project => @project,
                                :budget => 100, :spend => 200)
      code     = Factory.create(:code, :short_display => 'code1')

      ca1      = Factory.create(:coding_budget, :activity => activity, :code => code)
      ca2      = Factory.create(:coding_spend,  :activity => activity, :code => code)

      CodeAssignment.with_type('CodingBudget').should == [ca1]
      CodeAssignment.with_type('CodingSpend').should == [ca2]
    end

    it "cached_amount_desc" do
      basic_setup_project
      activity = Factory.create(:activity, :data_response => @response, :project => @project,
                                :budget => 100, :spend => 200)

      code     = Factory.create(:code, :short_display => 'code1')

      ca1      = Factory.create(:coding_budget, :activity => activity, :code => code, :cached_amount => '100')
      ca2      = Factory.create(:coding_spend,  :activity => activity, :code => code, :cached_amount => '101')

      ca1.cached_amount.should == 100
      ca2.cached_amount.should == 101
      CodeAssignment.all.should == [ca1, ca2]
      CodeAssignment.cached_amount_desc.should == [ca2, ca1]
    end

    it "select_for_pies" do
      Money.default_bank.add_rate(:USD, :RWF, "500")

      organization = Factory(:organization, :currency => 'USD')
      request      = Factory(:data_request, :organization => organization)
      response     = organization.latest_response
      project      = Factory(:project, :data_response => response)
      activity1    = Factory.create(:activity,
                                    :data_response => response, :project => project,
                                    :budget => 100, :spend => 200)
      activity2    = Factory.create(:activity,
                                    :data_response => response, :project => project,
                                    :budget => 100, :spend => 200)
      code1        = Factory.create(:code, :short_display => 'code1')
      code2        = Factory.create(:code, :short_display => 'code2')
      ca1          = Factory.create(:coding_budget, :activity => activity1, :code => code1,
                                    :cached_amount => 1, :cached_amount_in_usd => 1)
      ca2          = Factory.create(:coding_spend,  :activity => activity1, :code => code2,
                                    :cached_amount => 11)
      ca1          = Factory.create(:coding_budget, :activity => activity1, :code => code1,
                                    :cached_amount => 2)
      ca2          = Factory.create(:coding_spend,  :activity => activity1, :code => code2,
                                    :cached_amount => 12)

      code_assignments = CodeAssignment.select_for_pies.all

      code_assignments[0].code_id.should == code2.id

      if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
        code_assignments[0].value.should == "23.0"
      else # sqlite3
        code_assignments[0].value.should == 23.0
      end

      code_assignments[1].code_id.should == code1.id

      if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
        code_assignments[1].value.should == "3.0"
      else # sqlite3
        code_assignments[1].value.should == 3.0
      end
    end
  end

  describe "updating amounts" do
    before :each do
      basic_setup_project
      activity = Factory.create(:activity, :data_response => @response, :project => @project,
                                :budget => 100, :spend => 200)
      @assignment = Factory(:code_assignment, :activity => activity)
    end

    it "should allow updating of amount with ints and floats" do
      [1234, 1234.4, 123.45, 123.4567].each do |value|
        @assignment.amount = value
        @assignment.save.should == true
        @assignment.reload
        @assignment.amount.should == value
      end
    end

    it "should allow updating of amount with strings" do
      update_amount_and_check(@assignment, '1234', '1234.0')
    end

    it "should allow updating of float amounts with strings" do
      ['1234.4', '123.45', '123.4567'].each do |value|
        update_amount_and_check(@assignment, value, value)
      end
    end
  end

  def update_amount_and_check(assignment, input, output)
    assignment.amount = input
    assignment.save.should == true
    assignment.reload
    assignment.amount.to_s.should == output
  end

  describe "keeping USD cached amounts in-sync" do
    before :each do
      Money.default_bank.add_rate(:RWF, :USD, 0.002)
      Money.default_bank.add_rate(:USD, :RWF, "500")

      @organization = Factory(:organization, :currency => 'RWF')
      @request      = Factory(:data_request, :organization => @organization)
      @response     = @organization.latest_response
      @project      = Factory(:project, :data_response => @response)
      @activity     = Factory(:activity, :data_response => @response, :project => @project)

      ###
      @ca               = Factory.build(:code_assignment, :activity => @activity)
      @ca.amount        = 123.45
      @ca.cached_amount = 123.45
      @ca.save
      @ca.reload
    end

    it "should update cached_amount_in_usd on creation" do
      @ca.cached_amount_in_usd.should == 0.2469 # sqlite precision!
    end

    it "should update cached_amount_in_usd on update" do
      @ca.cached_amount = 456.78
      @ca.save
      @ca.cached_amount_in_usd.should == 0.91356
    end
  end

  describe "::mass_update_classifications" do
    before :each do
      @organization = Factory(:organization)
      @request      = Factory(:data_request, :organization => @organization)
      @response     = @organization.latest_response
    end

    context "when activities does not exist" do
      it "does not saves anything" do
        classifications = {}
        coding_type     = 'CodingBudget'
        CodeAssignment.mass_update_classifications(@response, classifications, coding_type)
        CodeAssignment.count.should == 0
      end
    end

    context "when activities exist" do
      before :each do
        @project  = Factory(:project, :data_response => @response)
        @activity = Factory(:activity, :data_response => @response, :project => @project)
      end

      context "when classifications are blank" do
        it "does not saves anything" do
          classifications = {}
          coding_type     = 'CodingBudget'
          CodeAssignment.mass_update_classifications(@response, classifications, coding_type)
          CodeAssignment.count.should == 0
        end
      end

      context "when classifications are present" do
        it "saves code assignments" do
          code1 = Factory(:mtef_code)
          code2 = Factory(:mtef_code)
          classifications = { @activity.id.to_s => { code1.id => 10, code2.id => 20 } }
          coding_type     = 'CodingBudget'
          CodeAssignment.mass_update_classifications(@response, classifications, coding_type)
          CodeAssignment.count.should == 2
        end
      end
    end
  end

  describe "::update_classifications" do
    before :each do
      @organization = Factory(:organization)
      @request      = Factory(:data_request, :organization => @organization)
      @response     = @organization.latest_response
      @project      = Factory(:project, :data_response => @response)
      @activity     = Factory(:activity, :data_response => @response, :project => @project)
    end

    context "when classifications does not exist" do
      context "when submitting blank classifications" do
        it "does not saves anything" do
          classifications = {}
          coding_type     = 'CodingBudget'
          CodeAssignment.update_classifications(@activity, classifications, coding_type)
          CodeAssignment.count.should == 0
        end
      end

      context "when submitting classifications" do
        before :each do
          @code1 = Factory(:mtef_code)
          @code2 = Factory(:mtef_code)
        end

        context "when submitting amounts" do
          it "creates code assignments" do
            classifications = { @code1.id => 10, @code2.id => 20 }
            coding_type     = 'CodingBudget'
            CodeAssignment.update_classifications(@activity, classifications, coding_type)
            CodeAssignment.count.should == 2
          end
        end

        context "when submitting percentages" do
          it "creates code assignments" do
            classifications = { @code1.id => '40%', @code2.id => '20%' }
            coding_type     = 'CodingBudget'
            CodeAssignment.update_classifications(@activity, classifications, coding_type)
            CodeAssignment.count.should == 2

            code_assignments = CodeAssignment.all

            ca1 = code_assignments.detect{|ca| ca.code_id == @code1.id}
            ca1.amount.should == nil
            ca1.percentage.should == 40

            ca2 = code_assignments.detect{|ca| ca.code_id == @code2.id}
            ca2.amount.should == nil
            ca2.percentage.should == 20
          end
        end
      end
    end

    context "when classifications exist" do
      context "when submitting classifications" do
        before :each do
          @code1 = Factory(:mtef_code)
          @code2 = Factory(:mtef_code)
        end

        context "when submitting amounts" do
          it "updates code assignments" do
            Factory(:coding_budget, :activity => @activity, :code => @code1, :amount => 10)
            Factory(:coding_budget, :activity => @activity, :code => @code2, :amount => 20)
            CodeAssignment.count.should == 2

            # when submitting existing classifications, it updates them
            classifications = { @code1.id => 11, @code2.id => 22 }
            coding_type     = 'CodingBudget'
            CodeAssignment.update_classifications(@activity, classifications, coding_type)
            CodeAssignment.count.should == 2

            code_assignments = CodeAssignment.all
            code_assignments.detect{|ca| ca.code_id == @code1.id}.amount.should == 11
            code_assignments.detect{|ca| ca.code_id == @code2.id}.amount.should == 22
          end
        end

        context "when submitting percentages" do
          it "creates code assignments" do
            Factory(:coding_budget, :activity => @activity, :code => @code1, :percentage => 10)
            Factory(:coding_budget, :activity => @activity, :code => @code2, :amount => 20)
            CodeAssignment.count.should == 2

            # when submitting existing classifications, it updates them
            classifications = { @code1.id => '11%', @code2.id => '22%' }
            coding_type     = 'CodingBudget'
            CodeAssignment.update_classifications(@activity, classifications, coding_type)
            CodeAssignment.count.should == 2
            code_assignments = CodeAssignment.all
            code_assignments.detect{|ca| ca.code_id == @code1.id}.percentage.should == 11
            code_assignments.detect{|ca| ca.code_id == @code2.id}.percentage.should == 22
          end
        end
      end
    end
  end


  describe "classification level" do
    # If you delegate to implementer (that exists in HRT i.e.
    # not a health center), you only have to enter
    # Past Expenditure & Current Budget to Level D
    context "when organization delegates to implementer" do
      before :each do
        @organization = Factory(:organization)
        @request      = Factory(:data_request, :organization => @organization)
        @response     = @organization.latest_response
        @project      = Factory(:project, :data_response => @response)
        @activity     = Factory(:activity, :data_response => @response, :project => @project)
      end

      context "when implementer is a Health Center" do
        it "have to classify to the lowest level" do
          pending
          health_center = Factory(:organization, :raw_type => "Health Center")
          Factory(:sub_activity, :activity => @activity, :provider => health_center)
        end
      end

      context "when implementer is neither self neither a Health Center organization" do
        before :each do
          local_ngo = Factory(:organization, :raw_type => "Local NGO")
          Factory(:sub_activity, :activity => @activity, :data_response => @response,
                  :provider => local_ngo)
        end

        it "allows classifications to level 4" do
          CodeAssignment::DELEGATED_CLASSIFICATION_LEVEL.should == 4
        end

        it "allows classification for level 1" do
          purpose1        = Factory(:mtef_code)

          classifications = { purpose1.id => 1 }
          coding_type     = 'CodingBudget'
          CodeAssignment.update_classifications(@activity, classifications, coding_type)
          CodeAssignment.count.should == 1
        end

        it "allows classification for level 2" do
          purpose1        = Factory(:mtef_code)
          purpose2        = Factory(:mtef_code)
          purpose2.move_to_child_of(purpose1)

          classifications = { purpose2.id => 1 }
          coding_type     = 'CodingBudget'
          CodeAssignment.update_classifications(@activity, classifications, coding_type)
          CodeAssignment.count.should == 2
        end

        it "allows classification for level 3" do
          purpose1        = Factory(:mtef_code)
          purpose2        = Factory(:mtef_code)
          purpose2.move_to_child_of(purpose1)
          purpose3        = Factory(:mtef_code)
          purpose3.move_to_child_of(purpose2)

          classifications = { purpose3.id => 1 }
          coding_type     = 'CodingBudget'
          CodeAssignment.update_classifications(@activity, classifications, coding_type)
          CodeAssignment.count.should == 3
        end

        it "allows classification for level 4" do
          purpose1        = Factory(:mtef_code)
          purpose2        = Factory(:mtef_code)
          purpose2.move_to_child_of(purpose1)
          purpose3        = Factory(:mtef_code)
          purpose3.move_to_child_of(purpose2)
          purpose4        = Factory(:mtef_code)
          purpose4.move_to_child_of(purpose3)

          classifications = { purpose4.id => 1 }
          coding_type     = 'CodingBudget'
          CodeAssignment.update_classifications(@activity, classifications, coding_type)
          CodeAssignment.count.should == 4
        end

        it "does not allow classification for level 5" do
          purpose1        = Factory(:mtef_code)
          purpose2        = Factory(:mtef_code)
          purpose2.move_to_child_of(purpose1)
          purpose3        = Factory(:mtef_code)
          purpose3.move_to_child_of(purpose2)
          purpose4        = Factory(:mtef_code)
          purpose4.move_to_child_of(purpose3)
          purpose5        = Factory(:mtef_code)
          purpose5.move_to_child_of(purpose4)

          classifications = { purpose5.id => 1 }
          coding_type     = 'CodingBudget'
          CodeAssignment.update_classifications(@activity, classifications, coding_type)
          CodeAssignment.count.should == 0
        end
      end
    end

  end
end

# == Schema Information
#
# Table name: code_assignments
#
#  id                   :integer         primary key
#  activity_id          :integer
#  code_id              :integer
#  amount               :decimal(, )
#  type                 :string(255)
#  percentage           :decimal(, )
#  cached_amount        :decimal(, )     default(0.0)
#  sum_of_children      :decimal(, )     default(0.0)
#  created_at           :timestamp
#  updated_at           :timestamp
#  cached_amount_in_usd :decimal(, )     default(0.0)
#

