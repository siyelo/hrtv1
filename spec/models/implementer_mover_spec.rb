require File.dirname(__FILE__) + '/../spec_helper'

describe ImplementerMover do

  # we run the mover over existing data
  # so we only care about actual amount fields on activity (i.e. not cached yet)
  # disable the callbacks so we dont have any unintended caching side effects when setting up
  # scenarios
  before :all do
    SubActivity.after_save.reject! {|callback| callback.method.to_s == 'update_activity_cache'}
  end

  after :all do
    SubActivity.send :after_save, :update_activity_cache #re-enable callback
  end

  context "when activity has 1 provider (self)" do
    before :each do
      basic_setup_activity
      @activity.provider = @organization
      @activity.write_attribute(:spend, 4)
      @activity.write_attribute(:budget, 8)
      @activity.save
    end

    context "when no Implementer-Splits (IS) (aka Sub Activity)" do
      it "should move the provider to a new IS with amounts same as Activity amounts" do
        @activity.implementer_splits.should be_empty
        @activity.response.should_not be_nil
        @activity.data_response.should_not be_nil
        im = ImplementerMover.new(@activity)
        im.move!.should == true
        @activity.reload
        @activity.provider.should be_nil
        @activity.implementer_splits.size.should == 1
        @activity.implementer_splits[0].implementer.should == @organization
        @activity.implementer_splits[0].spend.to_f.should == 4
        @activity.implementer_splits[0].budget.to_f.should == 8
        @activity.sub_activities_total(:spend).should == 4
        @activity.sub_activities_total(:budget).should == 8
      end
    end

    context "when already 1 Implementer-Split (IS) (aka Sub Activity)" do
      context "when self is already in the IS" do
        before :each do
          @existing_split = SubActivity.new(:provider_id => @activity.provider.id,
                            :spend => @activity.spend, :budget => @activity.budget,
                            :data_response_id => @activity.response.id,
                            :activity_id => @activity.id)
          @existing_split.save!
        end

        it "should do nothing when IS.amount equals Activity.amount" do
          @activity.implementer_splits.size.should == 1 #sanity
          im = ImplementerMover.new(@activity)
          im.move!.should == true
          @activity.reload
          @activity.provider.should be_nil
          @activity.implementer_splits.size.should == 1 #sanity
          @activity.implementer_splits[0].implementer.should == @organization
          @activity.implementer_splits[0].spend.to_f.should == 4
          @activity.implementer_splits[0].budget.to_f.should == 8
          @activity.sub_activities_total(:spend).should == 4
          @activity.sub_activities_total(:budget).should == 8
        end

        it "should adjust IS split upwards to equal activity amount when current IS is less than activity amount" do
          @existing_split.spend = 1
          @existing_split.budget = 2
          @existing_split.save!
          @activity.implementer_splits.size.should == 1 #sanity
          im = ImplementerMover.new(@activity)
          im.move!.should == true
          @activity.reload
          @activity.provider.should be_nil
          @activity.implementer_splits.size.should == 1 #sanity
          @activity.implementer_splits[0].implementer.should == @organization
          @activity.implementer_splits[0].spend.to_f.should == 4
          @activity.implementer_splits[0].budget.to_f.should == 8
          @activity.sub_activities_total(:spend).should == 4
          @activity.sub_activities_total(:budget).should == 8
        end

        it "when IS exceeds activity, should just discard current provider+amount" do
          @existing_split.spend = 10
          @existing_split.budget = 20
          @existing_split.save!
          @activity.implementer_splits.size.should == 1 #sanity
          im = ImplementerMover.new(@activity)
          im.move!.should == true
          @activity.reload
          @activity.provider.should be_nil
          @activity.implementer_splits.size.should == 1 #sanity
          @activity.implementer_splits[0].implementer.should == @organization
          @activity.implementer_splits[0].spend.to_f.should == 10
          @activity.implementer_splits[0].budget.to_f.should == 20
          @activity.sub_activities_total(:spend).should == 10
          @activity.sub_activities_total(:budget).should == 20
        end
      end

      context "when self is NOT already in the IS" do
        before :each do
          @ngo1 = Factory :organization
          @existing_split = SubActivity.new(:provider_id => @ngo1.id,
                            :spend => @activity.spend, :budget => @activity.budget,
                            :data_response_id => @activity.response.id,
                            :activity_id => @activity.id)
          @existing_split.save!
        end

        it "should do nothing when IS amount matches Activity amount" do
          @activity.implementer_splits.size.should == 1 #sanity
          im = ImplementerMover.new(@activity)
          im.move!.should == true
          @activity.reload
          @activity.provider.should be_nil
          @activity.implementer_splits.size.should == 1 #sanity
          @activity.implementer_splits[0].implementer.should == @ngo1
          @activity.implementer_splits[0].spend.to_f.should == 4
          @activity.implementer_splits[0].budget.to_f.should == 8
          @activity.sub_activities_total(:spend).should == 4
          @activity.sub_activities_total(:budget).should == 8
        end

        it "should create new adjusted IS split, when current IS is less than activity amount" do
          # we treat Activity.budget as more accurate than SA.budget
          @existing_split.spend = 1
          @existing_split.budget = 2
          @existing_split.save!
          @activity.implementer_splits.size.should == 1 #sanity
          im = ImplementerMover.new(@activity)
          im.move!.should == true
          @activity.reload
          @activity.provider.should be_nil
          @activity.implementer_splits.size.should == 2 #sanity
          @activity.implementer_splits[0].implementer.should == @ngo1 #new self implementer
          @activity.implementer_splits[0].spend.to_f.should == 1
          @activity.implementer_splits[0].budget.to_f.should == 2
          @activity.implementer_splits[1].implementer.should == @organization #self
          @activity.implementer_splits[1].spend.to_f.should == 3 # new split, adjusted
          @activity.implementer_splits[1].budget.to_f.should == 6
          @activity.sub_activities_total(:spend).should == 4
          @activity.sub_activities_total(:budget).should == 8
        end

        it "when IS exceeds activity, should just discard current provider+amount" do
          @existing_split.spend = 10
          @existing_split.budget = 20
          @existing_split.save!
          @activity.implementer_splits.size.should == 1 #sanity
          im = ImplementerMover.new(@activity)
          im.move!.should == true
          @activity.reload
          @activity.provider.should be_nil
          @activity.implementer_splits.size.should == 1 #sanity
          @activity.implementer_splits[0].implementer.should == @ngo1
          @activity.implementer_splits[0].spend.to_f.should == 10
          @activity.implementer_splits[0].budget.to_f.should == 20
          @activity.sub_activities_total(:spend).should == 10
          @activity.sub_activities_total(:budget).should == 20
        end

        it "should adjust a single amount upwards when only one amount needs to be adjusted" do
          @existing_split.spend = 1
          # budget stays at 8
          @existing_split.save!
          @activity.implementer_splits.size.should == 1 #sanity
          im = ImplementerMover.new(@activity)
          im.move!.should == true
          @activity.reload
          @activity.provider.should be_nil
          @activity.implementer_splits.size.should == 2 #sanity
          @activity.implementer_splits[0].implementer.should == @ngo1
          @activity.implementer_splits[0].spend.to_f.should == 1
          @activity.implementer_splits[0].budget.to_f.should == 8
          @activity.implementer_splits[1].implementer.should == @organization #new self implementer
          @activity.implementer_splits[1].spend.to_f.should == 3
          @activity.implementer_splits[1].budget.to_f.should == 0
          @activity.sub_activities_total(:spend).should == 4
          @activity.sub_activities_total(:budget).should == 8
        end
      end
    end

    context "when already several Implementer-Splits (IS) (aka Sub Activity)" do
      before :each do
        @implementer1 = Factory(:organization)
        @implementer2 = Factory(:organization)
        @existing_split1 = SubActivity.new(:provider_id => @implementer1.id,
                          :spend => 2, :budget => 4,
                          :data_response_id => @activity.response.id,
                          :activity_id => @activity.id)
        @existing_split1.save!
        @existing_split2 = SubActivity.new(:provider_id => @implementer2.id,
                          :spend => 2, :budget => 4,
                          :data_response_id => @activity.response.id,
                          :activity_id => @activity.id)
        @existing_split2.save!
      end

     context "when self is already in the IS" do
        before :each do
          @existing_split1.provider = @organization
          @existing_split1.save!
        end

        it "should do nothing when IS amount matches Activity amount" do
          @activity.implementer_splits.size.should == 2 #sanity
          im = ImplementerMover.new(@activity)
          im.move!.should == true
          @activity.reload
          @activity.provider.should be_nil
          @activity.implementer_splits.size.should == 2 #sanity
          @activity.implementer_splits[0].implementer.should == @organization
          @activity.implementer_splits[1].implementer.should == @implementer2
          @activity.sub_activities_total(:spend).should == 4
          @activity.sub_activities_total(:budget).should == 8
        end

        it "should create new adjusted IS split, when current IS is less than activity amount" do
          # we treat Activity.budget as more accurate than SA.budget
          @existing_split1.spend = 1
          @existing_split1.budget = 2
          @existing_split1.save!
          @activity.implementer_splits.size.should == 2 #sanity
          im = ImplementerMover.new(@activity)
          im.move!.should == true
          @activity.reload
          @activity.provider.should be_nil
          @activity.implementer_splits.size.should == 2 #sanity
          @activity.implementer_splits[0].implementer.should == @organization
          @activity.implementer_splits[0].spend.to_f.should == 2 # it adjusted it back up
          @activity.implementer_splits[0].budget.to_f.should == 4 # it adjusted it back up
          @activity.implementer_splits[1].implementer.should == @implementer2 #sanity
          @activity.implementer_splits[1].spend.to_f.should == 2  #sanity
          @activity.implementer_splits[1].budget.to_f.should == 4 #sanity
          @activity.sub_activities_total(:spend).should == 4
          @activity.sub_activities_total(:budget).should == 8
        end

        it "when IS exceeds activity, should just discard current provider+amount" do
          @existing_split1.spend = 10
          @existing_split1.budget = 20
          @existing_split1.save!
          @activity.implementer_splits.size.should == 2 #sanity
          im = ImplementerMover.new(@activity)
          im.move!.should == true
          @activity.reload
          @activity.provider.should be_nil
          @activity.implementer_splits.size.should == 2 #sanity
          @activity.implementer_splits[0].implementer.should == @organization
          @activity.implementer_splits[1].implementer.should == @implementer2
          @activity.sub_activities_total(:spend).should == 12
          @activity.sub_activities_total(:budget).should == 24
        end

        it "should adjust a single amount upwards when only one amount needs to be adjusted" do
          @existing_split1.spend = 1
          # budget stays at 8
          @existing_split1.save!
          @activity.implementer_splits.size.should == 2 #sanity
          im = ImplementerMover.new(@activity)
          im.move!.should == true
          @activity.reload
          @activity.provider.should be_nil
          @activity.implementer_splits.size.should == 2 #sanity
          @activity.implementer_splits[0].implementer.should == @organization
          @activity.implementer_splits[0].spend.to_f.should == 2 # it adjusted it back up
          @activity.implementer_splits[0].budget.to_f.should == 4
          @activity.implementer_splits[1].implementer.should == @implementer2 # sanity
          @activity.implementer_splits[1].spend.to_f.should == 2 # sanity
          @activity.implementer_splits[1].budget.to_f.should == 4 # sanity
          @activity.sub_activities_total(:spend).should == 4
          @activity.sub_activities_total(:budget).should == 8
        end
      end

      context "when self is NOT already in the IS" do
        it "should do nothing when IS amount matches Activity amount" do
          @activity.implementer_splits.size.should == 2 #sanity
          im = ImplementerMover.new(@activity)
          im.move!.should == true
          @activity.reload
          @activity.provider.should be_nil
          @activity.implementer_splits.size.should == 2 #sanity
          @activity.implementer_splits[0].implementer.should == @implementer1
          @activity.implementer_splits[1].implementer.should == @implementer2
          @activity.sub_activities_total(:spend).should == 4
          @activity.sub_activities_total(:budget).should == 8
        end

        it "should create new adjusted IS split, when current IS is less than activity amount" do
          # we treat Activity.budget as more accurate than SA.budget
          @existing_split1.spend = 1
          @existing_split1.budget = 2
          @existing_split1.save!
          @activity.implementer_splits.size.should == 2 #sanity
          im = ImplementerMover.new(@activity)
          im.move!.should == true
          @activity.reload
          @activity.provider.should be_nil
          ### sanity
          @activity.implementer_splits.size.should == 3
          @activity.implementer_splits[0].implementer.should == @implementer1
          @activity.implementer_splits[0].spend.to_f.should == 1
          @activity.implementer_splits[0].budget.to_f.should == 2
          @activity.implementer_splits[1].implementer.should == @implementer2
          @activity.implementer_splits[1].spend.to_f.should == 2
          @activity.implementer_splits[1].budget.to_f.should == 4
          ### /sanity
          @activity.implementer_splits[2].implementer.should == @organization #new self implementer
          @activity.implementer_splits[2].spend.to_f.should == 1 # new split, adjusted
          @activity.implementer_splits[2].budget.to_f.should == 2
          @activity.sub_activities_total(:spend).should == 4
          @activity.sub_activities_total(:budget).should == 8
        end

        it "when IS exceeds activity, should just discard current provider+amount" do
          @existing_split1.spend = 10
          @existing_split1.budget = 20
          @existing_split1.save!
          @activity.implementer_splits.size.should == 2 #sanity
          im = ImplementerMover.new(@activity)
          im.move!.should == true
          @activity.reload
          @activity.provider.should be_nil
          @activity.implementer_splits.size.should == 2 #sanity
          @activity.implementer_splits[0].implementer.should == @implementer1
          @activity.implementer_splits[1].implementer.should == @implementer2
          @activity.sub_activities_total(:spend).should == 12
          @activity.sub_activities_total(:budget).should == 24
        end

        it "should adjust a single amount upwards when only one amount needs to be adjusted" do
          @existing_split1.spend = 1
          # budget stays at 8
          @existing_split1.save!
          @activity.implementer_splits.size.should == 2 #sanity
          im = ImplementerMover.new(@activity)
          im.move!.should == true
          @activity.reload
          @activity.provider.should be_nil
          ### sanity
          @activity.implementer_splits.size.should == 3 #sanity
          @activity.implementer_splits[0].implementer.should == @implementer1
          @activity.implementer_splits[0].spend.to_f.should == 1
          @activity.implementer_splits[0].budget.to_f.should == 4
          @activity.implementer_splits[1].implementer.should == @implementer2
          @activity.implementer_splits[1].spend.to_f.should == 2
          @activity.implementer_splits[1].budget.to_f.should == 4
          ### /sanity
          @activity.implementer_splits[2].implementer.should == @organization #new self implementer
          @activity.implementer_splits[2].spend.to_f.should == 1
          @activity.implementer_splits[2].budget.to_f.should == 0
          @activity.sub_activities_total(:spend).should == 4
          @activity.sub_activities_total(:budget).should == 8
        end
      end
      ###
    end
  end


  describe "when activity has 1 other provider (not self)" do
    before :each do
      basic_setup_activity
      @implementer = Factory(:organization)
      @activity.provider = @implementer
      @activity.write_attribute(:spend, 4)
      @activity.write_attribute(:budget, 8)
      @activity.save
    end

    context "when no Implementer-Splits (IS) (aka Sub Activity)" do
      it "should move the provider to a new IS with amounts same as Activity amounts" do
        @activity.implementer_splits.should be_empty
        @activity.response.should_not be_nil
        @activity.data_response.should_not be_nil
        im = ImplementerMover.new(@activity)
        im.move!.should == true
        @activity.reload
        @activity.provider.should be_nil
        @activity.implementer_splits.size.should == 1
        @activity.implementer_splits[0].implementer.should == @implementer
        @activity.implementer_splits[0].spend.to_f.should == 4
        @activity.implementer_splits[0].budget.to_f.should == 8
        @activity.sub_activities_total(:spend).should == 4
        @activity.sub_activities_total(:budget).should == 8
      end
    end

    context "when already 1 Implementer-Split (IS) (aka Sub Activity)" do
      context "when activity.provider is already in the IS" do
        before :each do
          @existing_split = SubActivity.new(:provider_id => @activity.provider.id,
                            :spend => @activity.spend, :budget => @activity.budget,
                            :data_response_id => @activity.response.id,
                            :activity_id => @activity.id)
          @existing_split.save!
        end

        it "should do nothing when IS.amount equals Activity.amount" do
          @activity.implementer_splits.size.should == 1 #sanity
          im = ImplementerMover.new(@activity)
          im.move!.should == true
          @activity.reload
          @activity.provider.should be_nil
          @activity.implementer_splits.size.should == 1 #sanity
          @activity.implementer_splits[0].implementer.should == @implementer
          @activity.implementer_splits[0].spend.to_f.should == 4
          @activity.implementer_splits[0].budget.to_f.should == 8
          @activity.sub_activities_total(:spend).should == 4
          @activity.sub_activities_total(:budget).should == 8
        end

        it "should adjust IS split upwards when current IS is less than activity amount" do
          # we treat Activity.budget as more accurate than SA.budget
          @existing_split.spend = 1
          @existing_split.budget = 2
          @existing_split.save!
          @activity.implementer_splits.size.should == 1 #sanity
          im = ImplementerMover.new(@activity)
          im.move!.should == true
          @activity.reload
          @activity.provider.should be_nil
          @activity.implementer_splits.size.should == 1 #sanity
          @activity.implementer_splits[0].implementer.should == @implementer
          @activity.implementer_splits[0].spend.to_f.should == 4
          @activity.implementer_splits[0].budget.to_f.should == 8
          @activity.sub_activities_total(:spend).should == 4
          @activity.sub_activities_total(:budget).should == 8
        end

        it "when IS exceeds activity, should just discard current provider+amount" do
          @existing_split.spend = 10
          @existing_split.budget = 20
          @existing_split.save!
          @activity.implementer_splits.size.should == 1 #sanity
          im = ImplementerMover.new(@activity)
          im.move!.should == true
          @activity.reload
          @activity.provider.should be_nil
          @activity.implementer_splits.size.should == 1 #sanity
          @activity.implementer_splits[0].implementer.should == @implementer
          @activity.implementer_splits[0].spend.to_f.should == 10
          @activity.implementer_splits[0].budget.to_f.should == 20
          @activity.sub_activities_total(:spend).should == 10
          @activity.sub_activities_total(:budget).should == 20
        end
      end

      context "when activity.provder is NOT already in the IS" do
        before :each do
          @ngo1 = Factory :organization
          @existing_split = SubActivity.new(:provider_id => @ngo1.id,
                            :spend => @activity.spend, :budget => @activity.budget,
                            :data_response_id => @activity.response.id,
                            :activity_id => @activity.id)
          @existing_split.save!
        end

        it "should do nothing when IS amount matches Activity amount" do
          @activity.implementer_splits.size.should == 1 #sanity
          im = ImplementerMover.new(@activity)
          im.move!.should == true
          @activity.reload
          @activity.provider.should be_nil
          @activity.implementer_splits.size.should == 1 #sanity
          @activity.implementer_splits[0].implementer.should == @ngo1
          @activity.implementer_splits[0].spend.to_f.should == 4
          @activity.implementer_splits[0].budget.to_f.should == 8
          @activity.sub_activities_total(:spend).should == 4
          @activity.sub_activities_total(:budget).should == 8
        end

        it "should create new adjusted IS split, when current IS is less than activity amount" do
          # we treat Activity.budget as more accurate than SA.budget
          @existing_split.spend = 1
          @existing_split.budget = 2
          @existing_split.save!
          @activity.implementer_splits.size.should == 1 #sanity
          im = ImplementerMover.new(@activity)
          im.move!.should == true
          @activity.reload
          @activity.provider.should be_nil
          @activity.implementer_splits.size.should == 2 #sanity
          @activity.implementer_splits[0].implementer.should == @ngo1 #new self implementer
          @activity.implementer_splits[0].spend.to_f.should == 1
          @activity.implementer_splits[0].budget.to_f.should == 2
          @activity.implementer_splits[1].implementer.should == @implementer #self
          @activity.implementer_splits[1].spend.to_f.should == 3 # new split, adjusted
          @activity.implementer_splits[1].budget.to_f.should == 6
          @activity.sub_activities_total(:spend).should == 4
          @activity.sub_activities_total(:budget).should == 8
        end

        it "when IS exceeds activity, should just discard current provider+amount" do
          @existing_split.spend = 10
          @existing_split.budget = 20
          @existing_split.save!
          @activity.implementer_splits.size.should == 1 #sanity
          im = ImplementerMover.new(@activity)
          im.move!.should == true
          @activity.reload
          @activity.provider.should be_nil
          @activity.implementer_splits.size.should == 1 #sanity
          @activity.implementer_splits[0].implementer.should == @ngo1
          @activity.implementer_splits[0].spend.to_f.should == 10
          @activity.implementer_splits[0].budget.to_f.should == 20
          @activity.sub_activities_total(:spend).should == 10
          @activity.sub_activities_total(:budget).should == 20
        end

        it "should adjust a single amount upwards when only one amount needs to be adjusted" do
          @existing_split.spend = 1
          # budget stays at 8
          @existing_split.save!
          @activity.implementer_splits.size.should == 1 #sanity
          im = ImplementerMover.new(@activity)
          im.move!.should == true
          @activity.reload
          @activity.provider.should be_nil
          @activity.implementer_splits.size.should == 2 #sanity
          @activity.implementer_splits[0].implementer.should == @ngo1
          @activity.implementer_splits[0].spend.to_f.should == 1
          @activity.implementer_splits[0].budget.to_f.should == 8
          @activity.implementer_splits[1].implementer.should == @implementer #new self implementer
          @activity.implementer_splits[1].spend.to_f.should == 3
          @activity.implementer_splits[1].budget.to_f.should == 0
          @activity.sub_activities_total(:spend).should == 4
          @activity.sub_activities_total(:budget).should == 8
        end
      end
    end

    context "when already several Implementer-Splits (IS) (aka Sub Activity)" do
      before :each do
        @implementer1 = Factory(:organization)
        @implementer2 = Factory(:organization)
        @existing_split1 = SubActivity.new(:provider_id => @implementer1.id,
                          :spend => 2, :budget => 4,
                          :data_response_id => @activity.response.id,
                          :activity_id => @activity.id)
        @existing_split1.save!
        @existing_split2 = SubActivity.new(:provider_id => @implementer2.id,
                          :spend => 2, :budget => 4,
                          :data_response_id => @activity.response.id,
                          :activity_id => @activity.id)
        @existing_split2.save!
      end

     context "when activity.provider is already in the IS" do
        before :each do
          @existing_split1.provider = @implementer
          @existing_split1.save!
        end

        it "should do nothing when IS amount matches Activity amount" do
          @activity.implementer_splits.size.should == 2 #sanity
          im = ImplementerMover.new(@activity)
          im.move!.should == true
          @activity.reload
          @activity.provider.should be_nil
          @activity.implementer_splits.size.should == 2 #sanity
          @activity.implementer_splits[0].implementer.should == @implementer
          @activity.implementer_splits[1].implementer.should == @implementer2
          @activity.sub_activities_total(:spend).should == 4
          @activity.sub_activities_total(:budget).should == 8
        end

        it "should create new adjusted IS split, when current IS is less than activity amount" do
          # we treat Activity.budget as more accurate than SA.budget
          @existing_split1.spend = 1
          @existing_split1.budget = 2
          @existing_split1.save!
          @activity.implementer_splits.size.should == 2 #sanity
          im = ImplementerMover.new(@activity)
          im.move!.should == true
          @activity.reload
          @activity.provider.should be_nil
          @activity.implementer_splits.size.should == 2 #sanity
          @activity.implementer_splits[0].implementer.should == @implementer
          @activity.implementer_splits[0].spend.to_f.should == 2 # it adjusted it back up
          @activity.implementer_splits[0].budget.to_f.should == 4 # it adjusted it back up
          @activity.implementer_splits[1].implementer.should == @implementer2 #sanity
          @activity.implementer_splits[1].spend.to_f.should == 2  #sanity
          @activity.implementer_splits[1].budget.to_f.should == 4 #sanity
          @activity.sub_activities_total(:spend).should == 4
          @activity.sub_activities_total(:budget).should == 8
        end

        it "when IS exceeds activity, should just discard current provider+amount" do
          @existing_split1.spend = 10
          @existing_split1.budget = 20
          @existing_split1.save!
          @activity.implementer_splits.size.should == 2 #sanity
          im = ImplementerMover.new(@activity)
          im.move!.should == true
          @activity.reload
          @activity.provider.should be_nil
          @activity.implementer_splits.size.should == 2 #sanity
          @activity.implementer_splits[0].implementer.should == @implementer
          @activity.implementer_splits[1].implementer.should == @implementer2
          @activity.sub_activities_total(:spend).should == 12
          @activity.sub_activities_total(:budget).should == 24
        end

        it "should adjust a single amount upwards when only one amount needs to be adjusted" do
          @existing_split1.spend = 1
          # budget stays at 8
          @existing_split1.save!
          @activity.implementer_splits.size.should == 2 #sanity
          im = ImplementerMover.new(@activity)
          im.move!.should == true
          @activity.reload
          @activity.provider.should be_nil
          @activity.implementer_splits.size.should == 2 #sanity
          @activity.implementer_splits[0].implementer.should == @implementer
          @activity.implementer_splits[0].spend.to_f.should == 2 # it adjusted it back up
          @activity.implementer_splits[0].budget.to_f.should == 4
          @activity.implementer_splits[1].implementer.should == @implementer2 # sanity
          @activity.implementer_splits[1].spend.to_f.should == 2 # sanity
          @activity.implementer_splits[1].budget.to_f.should == 4 # sanity
          @activity.sub_activities_total(:spend).should == 4
          @activity.sub_activities_total(:budget).should == 8
        end
      end

      context "when activity.provider is NOT already in the IS" do
        it "should do nothing when IS amount matches Activity amount" do
          @activity.implementer_splits.size.should == 2 #sanity
          im = ImplementerMover.new(@activity)
          im.move!.should == true
          @activity.reload
          @activity.provider.should be_nil
          @activity.implementer_splits.size.should == 2 #sanity
          @activity.implementer_splits[0].implementer.should == @implementer1
          @activity.implementer_splits[1].implementer.should == @implementer2
          @activity.sub_activities_total(:spend).should == 4
          @activity.sub_activities_total(:budget).should == 8
        end

        it "should create new adjusted IS split, when current IS is less than activity amount" do
          # we treat Activity.budget as more accurate than SA.budget
          @existing_split1.spend = 1
          @existing_split1.budget = 2
          @existing_split1.save!
          @activity.implementer_splits.size.should == 2 #sanity
          im = ImplementerMover.new(@activity)
          im.move!.should == true
          @activity.reload
          @activity.provider.should be_nil
          ### sanity
          @activity.implementer_splits.size.should == 3
          @activity.implementer_splits[0].implementer.should == @implementer1
          @activity.implementer_splits[0].spend.to_f.should == 1
          @activity.implementer_splits[0].budget.to_f.should == 2
          @activity.implementer_splits[1].implementer.should == @implementer2
          @activity.implementer_splits[1].spend.to_f.should == 2
          @activity.implementer_splits[1].budget.to_f.should == 4
          ### /sanity
          @activity.implementer_splits[2].implementer.should == @implementer #new entry
          @activity.implementer_splits[2].spend.to_f.should == 1 # new split, adjusted
          @activity.implementer_splits[2].budget.to_f.should == 2
          @activity.sub_activities_total(:spend).should == 4
          @activity.sub_activities_total(:budget).should == 8
        end

        it "when IS exceeds activity, should just discard current provider+amount" do
          @existing_split1.spend = 10
          @existing_split1.budget = 20
          @existing_split1.save!
          @activity.implementer_splits.size.should == 2 #sanity
          im = ImplementerMover.new(@activity)
          im.move!.should == true
          @activity.reload
          @activity.provider.should be_nil
          @activity.implementer_splits.size.should == 2 #sanity
          @activity.implementer_splits[0].implementer.should == @implementer1
          @activity.implementer_splits[1].implementer.should == @implementer2
          @activity.sub_activities_total(:spend).should == 12
          @activity.sub_activities_total(:budget).should == 24
        end

        it "should adjust a single amount upwards when only one amount needs to be adjusted" do
          @existing_split1.spend = 1
          # budget stays at 8
          @existing_split1.save!
          @activity.implementer_splits.size.should == 2 #sanity
          im = ImplementerMover.new(@activity)
          im.move!.should == true
          @activity.reload
          @activity.provider.should be_nil
          ### sanity
          @activity.implementer_splits.size.should == 3 #sanity
          @activity.implementer_splits[0].implementer.should == @implementer1
          @activity.implementer_splits[0].spend.to_f.should == 1
          @activity.implementer_splits[0].budget.to_f.should == 4
          @activity.implementer_splits[1].implementer.should == @implementer2
          @activity.implementer_splits[1].spend.to_f.should == 2
          @activity.implementer_splits[1].budget.to_f.should == 4
          ### /sanity
          @activity.implementer_splits[2].implementer.should == @implementer # creates this
          @activity.implementer_splits[2].spend.to_f.should == 1
          @activity.implementer_splits[2].budget.to_f.should == 0
          @activity.sub_activities_total(:spend).should == 4
          @activity.sub_activities_total(:budget).should == 8
        end
      end
      ###
    end
  end


  describe "when activity has no provider" do
    before :each do
      basic_setup_activity
      @activity.provider = nil
      @activity.write_attribute(:spend, 4)
      @activity.write_attribute(:budget, 8)
      @activity.save
    end

    context "when no Implementer-Splits (IS) (aka Sub Activity)" do
      it "should move the provider to a new IS with amounts same as Activity amounts" do
        @activity.implementer_splits.should be_empty
        @activity.response.should_not be_nil
        @activity.data_response.should_not be_nil
        im = ImplementerMover.new(@activity)
        im.move!.should == true
        @activity.reload
        @activity.provider.should be_nil
        @activity.implementer_splits.size.should == 1
        @activity.implementer_splits[0].implementer.should == @organization
        @activity.implementer_splits[0].spend.to_f.should == 4
        @activity.implementer_splits[0].budget.to_f.should == 8
        @activity.sub_activities_total(:spend).should == 4
        @activity.sub_activities_total(:budget).should == 8
      end
    end

    context "when already 1 Implementer-Split (IS) (aka Sub Activity)" do
      context "when provider is NOT already in the IS (duh, its nil)" do
        before :each do
          @ngo1 = Factory :organization
          @existing_split = SubActivity.new(:provider_id => @ngo1.id,
                            :spend => @activity.spend, :budget => @activity.budget,
                            :data_response_id => @activity.response.id,
                            :activity_id => @activity.id)
          @existing_split.save!
        end

        it "should do nothing when IS amount matches Activity amount" do
          @activity.implementer_splits.size.should == 1 #sanity
          im = ImplementerMover.new(@activity)
          im.move!.should == true
          @activity.reload
          @activity.provider.should be_nil
          @activity.implementer_splits.size.should == 1 #sanity
          @activity.implementer_splits[0].implementer.should == @ngo1
          @activity.implementer_splits[0].spend.to_f.should == 4
          @activity.implementer_splits[0].budget.to_f.should == 8
          @activity.sub_activities_total(:spend).should == 4
          @activity.sub_activities_total(:budget).should == 8
        end

        it "should create new adjusted IS split, when current IS is less than activity amount" do
          # we treat Activity.budget as more accurate than SA.budget
          @existing_split.spend = 1
          @existing_split.budget = 2
          @existing_split.save!
          @activity.implementer_splits.size.should == 1 #sanity
          im = ImplementerMover.new(@activity)
          im.move!.should == true
          @activity.reload
          @activity.provider.should be_nil
          @activity.implementer_splits.size.should == 2 #sanity
          @activity.implementer_splits[0].implementer.should == @ngo1 #new self implementer
          @activity.implementer_splits[0].spend.to_f.should == 1
          @activity.implementer_splits[0].budget.to_f.should == 2
          @activity.implementer_splits[1].implementer.should == @organization #self
          @activity.implementer_splits[1].spend.to_f.should == 3 # new split, adjusted
          @activity.implementer_splits[1].budget.to_f.should == 6
          @activity.sub_activities_total(:spend).should == 4
          @activity.sub_activities_total(:budget).should == 8
        end

        it "when IS exceeds activity, should just discard current provider+amount" do
          @existing_split.spend = 10
          @existing_split.budget = 20
          @existing_split.save!
          @activity.implementer_splits.size.should == 1 #sanity
          im = ImplementerMover.new(@activity)
          im.move!.should == true
          @activity.reload
          @activity.provider.should be_nil
          @activity.implementer_splits.size.should == 1 #sanity
          @activity.implementer_splits[0].implementer.should == @ngo1
          @activity.implementer_splits[0].spend.to_f.should == 10
          @activity.implementer_splits[0].budget.to_f.should == 20
          @activity.sub_activities_total(:spend).should == 10
          @activity.sub_activities_total(:budget).should == 20
        end

        it "should adjust a single amount upwards when only one amount needs to be adjusted" do
          @existing_split.spend = 1
          # budget stays at 8
          @existing_split.save!
          @activity.implementer_splits.size.should == 1 #sanity
          im = ImplementerMover.new(@activity)
          im.move!.should == true
          @activity.reload
          @activity.provider.should be_nil
          @activity.implementer_splits.size.should == 2 #sanity
          @activity.implementer_splits[0].implementer.should == @ngo1
          @activity.implementer_splits[0].spend.to_f.should == 1
          @activity.implementer_splits[0].budget.to_f.should == 8
          @activity.implementer_splits[1].implementer.should == @organization #new self implementer
          @activity.implementer_splits[1].spend.to_f.should == 3
          @activity.implementer_splits[1].budget.to_f.should == 0
          @activity.sub_activities_total(:spend).should == 4
          @activity.sub_activities_total(:budget).should == 8
        end
      end
    end

    context "when already several Implementer-Splits (IS) (aka Sub Activity)" do
      before :each do
        @implementer1 = Factory(:organization)
        @implementer2 = Factory(:organization)
        @existing_split1 = SubActivity.new(:provider_id => @implementer1.id,
                          :spend => 2, :budget => 4,
                          :data_response_id => @activity.response.id,
                          :activity_id => @activity.id)
        @existing_split1.save!
        @existing_split2 = SubActivity.new(:provider_id => @implementer2.id,
                          :spend => 2, :budget => 4,
                          :data_response_id => @activity.response.id,
                          :activity_id => @activity.id)
        @existing_split2.save!
      end

     context "when self is already in the IS" do
        before :each do
          @existing_split1.provider = @organization
          @existing_split1.save!
        end

        it "should do nothing when IS amount matches Activity amount" do
          @activity.implementer_splits.size.should == 2 #sanity
          im = ImplementerMover.new(@activity)
          im.move!.should == true
          @activity.reload
          @activity.provider.should be_nil
          @activity.implementer_splits.size.should == 2 #sanity
          @activity.implementer_splits[0].implementer.should == @organization
          @activity.implementer_splits[1].implementer.should == @implementer2
          @activity.sub_activities_total(:spend).should == 4
          @activity.sub_activities_total(:budget).should == 8
        end

        it "should create new adjusted IS split, when current IS is less than activity amount" do
          # we treat Activity.budget as more accurate than SA.budget
          @existing_split1.spend = 1
          @existing_split1.budget = 2
          @existing_split1.save!
          @activity.implementer_splits.size.should == 2 #sanity
          im = ImplementerMover.new(@activity)
          im.move!.should == true
          @activity.reload
          @activity.provider.should be_nil
          @activity.implementer_splits.size.should == 2 #sanity
          @activity.implementer_splits[0].implementer.should == @organization
          @activity.implementer_splits[0].spend.to_f.should == 2 # it adjusted it back up
          @activity.implementer_splits[0].budget.to_f.should == 4 # it adjusted it back up
          @activity.implementer_splits[1].implementer.should == @implementer2 #sanity
          @activity.implementer_splits[1].spend.to_f.should == 2  #sanity
          @activity.implementer_splits[1].budget.to_f.should == 4 #sanity
          @activity.sub_activities_total(:spend).should == 4
          @activity.sub_activities_total(:budget).should == 8
        end

        it "when IS exceeds activity, should just discard current provider+amount" do
          @existing_split1.spend = 10
          @existing_split1.budget = 20
          @existing_split1.save!
          @activity.implementer_splits.size.should == 2 #sanity
          im = ImplementerMover.new(@activity)
          im.move!.should == true
          @activity.reload
          @activity.provider.should be_nil
          @activity.implementer_splits.size.should == 2 #sanity
          @activity.implementer_splits[0].implementer.should == @organization
          @activity.implementer_splits[1].implementer.should == @implementer2
          @activity.sub_activities_total(:spend).should == 12
          @activity.sub_activities_total(:budget).should == 24
        end

        it "should adjust a single amount upwards when only one amount needs to be adjusted" do
          @existing_split1.spend = 1
          # budget stays at 8
          @existing_split1.save!
          @activity.implementer_splits.size.should == 2 #sanity
          im = ImplementerMover.new(@activity)
          im.move!.should == true
          @activity.reload
          @activity.provider.should be_nil
          @activity.implementer_splits.size.should == 2 #sanity
          @activity.implementer_splits[0].implementer.should == @organization
          @activity.implementer_splits[0].spend.to_f.should == 2 # it adjusted it back up
          @activity.implementer_splits[0].budget.to_f.should == 4
          @activity.implementer_splits[1].implementer.should == @implementer2 # sanity
          @activity.implementer_splits[1].spend.to_f.should == 2 # sanity
          @activity.implementer_splits[1].budget.to_f.should == 4 # sanity
          @activity.sub_activities_total(:spend).should == 4
          @activity.sub_activities_total(:budget).should == 8
        end
      end

      context "when self is NOT already in the IS" do
        it "should do nothing when IS amount matches Activity amount" do
          @activity.implementer_splits.size.should == 2 #sanity
          im = ImplementerMover.new(@activity)
          im.move!.should == true
          @activity.reload
          @activity.provider.should be_nil
          @activity.implementer_splits.size.should == 2 #sanity
          @activity.implementer_splits[0].implementer.should == @implementer1
          @activity.implementer_splits[1].implementer.should == @implementer2
          @activity.sub_activities_total(:spend).should == 4
          @activity.sub_activities_total(:budget).should == 8
        end

        it "should create new adjusted IS split, when current IS is less than activity amount" do
          # we treat Activity.budget as more accurate than SA.budget
          @existing_split1.spend = 1
          @existing_split1.budget = 2
          @existing_split1.save!
          @activity.implementer_splits.size.should == 2 #sanity
          im = ImplementerMover.new(@activity)
          im.move!.should == true
          @activity.reload
          @activity.provider.should be_nil
          ### sanity
          @activity.implementer_splits.size.should == 3
          @activity.implementer_splits[0].implementer.should == @implementer1
          @activity.implementer_splits[0].spend.to_f.should == 1
          @activity.implementer_splits[0].budget.to_f.should == 2
          @activity.implementer_splits[1].implementer.should == @implementer2
          @activity.implementer_splits[1].spend.to_f.should == 2
          @activity.implementer_splits[1].budget.to_f.should == 4
          ### /sanity
          @activity.implementer_splits[2].implementer.should == @organization #new self implementer
          @activity.implementer_splits[2].spend.to_f.should == 1 # new split, adjusted
          @activity.implementer_splits[2].budget.to_f.should == 2
          @activity.sub_activities_total(:spend).should == 4
          @activity.sub_activities_total(:budget).should == 8
        end

        it "when IS exceeds activity, should just discard current provider+amount" do
          @existing_split1.spend = 10
          @existing_split1.budget = 20
          @existing_split1.save!
          @activity.implementer_splits.size.should == 2 #sanity
          im = ImplementerMover.new(@activity)
          im.move!.should == true
          @activity.reload
          @activity.provider.should be_nil
          @activity.implementer_splits.size.should == 2 #sanity
          @activity.implementer_splits[0].implementer.should == @implementer1
          @activity.implementer_splits[1].implementer.should == @implementer2
          @activity.sub_activities_total(:spend).should == 12
          @activity.sub_activities_total(:budget).should == 24
        end

        it "should adjust a single amount upwards when only one amount needs to be adjusted" do
          @existing_split1.spend = 1
          # budget stays at 8
          @existing_split1.save!
          @activity.implementer_splits.size.should == 2 #sanity
          im = ImplementerMover.new(@activity)
          im.move!.should == true
          @activity.reload
          @activity.provider.should be_nil
          ### sanity
          @activity.implementer_splits.size.should == 3 #sanity
          @activity.implementer_splits[0].implementer.should == @implementer1
          @activity.implementer_splits[0].spend.to_f.should == 1
          @activity.implementer_splits[0].budget.to_f.should == 4
          @activity.implementer_splits[1].implementer.should == @implementer2
          @activity.implementer_splits[1].spend.to_f.should == 2
          @activity.implementer_splits[1].budget.to_f.should == 4
          ### /sanity
          @activity.implementer_splits[2].implementer.should == @organization #new self implementer
          @activity.implementer_splits[2].spend.to_f.should == 1
          @activity.implementer_splits[2].budget.to_f.should == 0
          @activity.sub_activities_total(:spend).should == 4
          @activity.sub_activities_total(:budget).should == 8
        end
      end
      ###
    end
  end
end