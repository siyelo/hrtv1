require File.dirname(__FILE__) + '/../../spec_helper'

describe Organization, "FiscalYear" do
  describe "#usg?" do
    context "when fiscal_year_start_date is nil" do
      it "returns true" do
        o = Factory.build(:organization, :fiscal_year_start_date => nil)
        o.usg?.should be_false
      end
    end

    context "when fiscal_year_start_date is 2010-10-01" do
      it "returns true" do
        o = Factory.build(:organization, :fiscal_year_start_date => Date.parse("2010-10-01"))
        o.usg?.should be_true
      end
    end

    context "when fiscal_year_start_date month is any other than 10" do
      it "returns false" do
        o = Factory.build(:organization)
        o.fiscal_year_start_date = Date.parse("2010-01-01")
        o.usg?.should be_false
        o.fiscal_year_start_date = Date.parse("2010-02-01")
        o.usg?.should be_false
        o.fiscal_year_start_date = Date.parse("2010-03-01")
        o.usg?.should be_false
        o.fiscal_year_start_date = Date.parse("2010-04-01")
        o.usg?.should be_false
        o.fiscal_year_start_date = Date.parse("2010-05-01")
        o.usg?.should be_false
        o.fiscal_year_start_date = Date.parse("2010-06-01")
        o.usg?.should be_false
        o.fiscal_year_start_date = Date.parse("2010-07-01")
        o.usg?.should be_false
        o.fiscal_year_start_date = Date.parse("2010-08-01")
        o.usg?.should be_false
        o.fiscal_year_start_date = Date.parse("2010-09-01")
        o.usg?.should be_false
        o.fiscal_year_start_date = Date.parse("2010-11-01")
        o.usg?.should be_false
        o.fiscal_year_start_date = Date.parse("2010-12-01")
        o.usg?.should be_false
      end
    end
  end

  describe "#gor?" do
    context "when fiscal_year_start_date is nil" do
      it "returns true" do
        o = Factory.build(:organization, :fiscal_year_start_date => nil)
        o.gor?.should be_false
      end
    end

    context "when fiscal_year_start_date is 2010-07-01" do
      it "returns true" do
        o = Factory.build(:organization, :fiscal_year_start_date => Date.parse("2010-07-01"))
        o.gor?.should be_true
      end
    end

    context "when fiscal_year_start_date month is any other than 10" do
      it "returns false" do
        o = Factory.build(:organization)
        o.fiscal_year_start_date = Date.parse("2010-01-01")
        o.gor?.should be_false
        o.fiscal_year_start_date = Date.parse("2010-02-01")
        o.gor?.should be_false
        o.fiscal_year_start_date = Date.parse("2010-03-01")
        o.gor?.should be_false
        o.fiscal_year_start_date = Date.parse("2010-04-01")
        o.gor?.should be_false
        o.fiscal_year_start_date = Date.parse("2010-05-01")
        o.gor?.should be_false
        o.fiscal_year_start_date = Date.parse("2010-06-01")
        o.gor?.should be_false
        o.fiscal_year_start_date = Date.parse("2010-08-01")
        o.gor?.should be_false
        o.fiscal_year_start_date = Date.parse("2010-09-01")
        o.gor?.should be_false
        o.fiscal_year_start_date = Date.parse("2010-10-01")
        o.gor?.should be_false
        o.fiscal_year_start_date = Date.parse("2010-11-01")
        o.gor?.should be_false
        o.fiscal_year_start_date = Date.parse("2010-12-01")
        o.gor?.should be_false
      end
    end
  end

  describe "#quarter_label" do
    context "when organization is in USG FY" do
      before :each do
        @organization = Factory.build(:organization,
                          :fiscal_year_start_date => Date.parse("2010-10-01"))
        Timecop.freeze(Date.parse("2010-07-01"))
      end

      context "spend" do
        context "q4_prev" do
          it "returns Jul '09 - Sep '09" do
            @organization.quarter_label(:spend, "q4_prev").should == "Jul '09 - Sep '09"
          end
        end

        context "q1" do
          it "returns Oct '09 - Dec '09" do
            @organization.quarter_label(:spend, "q1").should == "Oct '09 - Dec '09"
          end
        end

        context "q2" do
          it "returns Jan '10 - Mar '10" do
            @organization.quarter_label(:spend, "q2").should == "Jan '10 - Mar '10"
          end
        end

        context "q3" do
          it "returns Apr '10 - Jun '10" do
            @organization.quarter_label(:spend, "q3").should == "Apr '10 - Jun '10"
          end
        end

        context "q4" do
          it "returns Jul '10 - Sep '10" do
            @organization.quarter_label(:spend, "q4").should == "Jul '10 - Sep '10"
          end
        end
      end

      context "budget" do
        context "q4_prev" do
          it "returns Jul '10 - Sep '10" do
            @organization.quarter_label(:budget, "q4_prev").should == "Jul '10 - Sep '10"
          end
        end

        context "q1" do
          it "returns Oct '10 - Dec '10" do
            @organization.quarter_label(:budget, "q1").should == "Oct '10 - Dec '10"
          end
        end

        context "q2" do
          it "returns Jan '11 - Mar '11" do
            @organization.quarter_label(:budget, "q2").should == "Jan '11 - Mar '11"
          end
        end

        context "q3" do
          it "returns Apr '11 - Jun '11" do
            @organization.quarter_label(:budget, "q3").should == "Apr '11 - Jun '11"
          end
        end

        context "q4" do
          it "returns Jul '11 - Sep '11" do
            @organization.quarter_label(:budget, "q4").should == "Jul '11 - Sep '11"
          end
        end
      end
    end

    context "when organization is in GOR FY" do
      before :each do
        @organization = Factory.build(:organization,
                          :fiscal_year_start_date => Date.parse("2010-07-01"))
        Timecop.freeze(Date.parse("2010-07-01"))
      end

      context "spend" do
        context "q4_prev" do
          it "returns Apr '09 - Jun '09" do
            @organization.quarter_label(:spend, "q4_prev").should == "Apr '09 - Jun '09"
          end
        end

        context "q1" do
          it "returns Jul '09 - Sep '09" do
            @organization.quarter_label(:spend, "q1").should == "Jul '09 - Sep '09"
          end
        end

        context "q2" do
          it "returns Oct '09 - Dec '09" do
            @organization.quarter_label(:spend, "q2").should == "Oct '09 - Dec '09"
          end
        end

        context "q3" do
          it "returns Jan '10 - Mar '10" do
            @organization.quarter_label(:spend, "q3").should == "Jan '10 - Mar '10"
          end
        end

        context "q4" do
          it "returns Apr '10 - Jun '10" do
            @organization.quarter_label(:spend, "q4").should == "Apr '10 - Jun '10"
          end
        end
      end

      context "budget" do
        context "q4_prev" do
          it "returns Apr '10 - Jun '10" do
            @organization.quarter_label(:budget, "q4_prev").should == "Apr '10 - Jun '10"
          end
        end

        context "q1" do
          it "returns Jul '10 - Sep '10" do
            @organization.quarter_label(:budget, "q1").should == "Jul '10 - Sep '10"
          end
        end

        context "q2" do
          it "returns Oct '10 - Dec '10" do
            @organization.quarter_label(:budget, "q2").should == "Oct '10 - Dec '10"
          end
        end

        context "q3" do
          it "returns Jan '11 - Mar '11" do
            @organization.quarter_label(:budget, "q3").should == "Jan '11 - Mar '11"
          end
        end

        context "q4" do
          it "returns Apr '11 - Jun '11" do
            @organization.quarter_label(:budget, "q4").should == "Apr '11 - Jun '11"
          end
        end
      end
    end
  end

  describe "#gor_fiscal_year_start" do
    before :each do
      @organization = Factory.build(:organization,
                        :fiscal_year_start_date => Date.parse("2010-07-01"))
    end

    context "when type is invalid" do
      it "raises an exception" do
        lambda { @organization.gor_fiscal_year_start('invalid')
        }.should raise_exception(Organization::FiscalYear::InvalidFiscalYearType)
      end
    end

    context "when type is spend" do
      context "when today is 2010-07-15" do
        it "start is 2009-07-01 and end is 2010-06-30" do
          Timecop.freeze(Date.parse("2010-07-15"))
          @organization.gor_fiscal_year_start(:spend).should == [2009, 2010]
        end
      end

      context "when today is 2010-06-15" do
        it "start is 2008-07-01 and end is 2009-06-30" do
          Timecop.freeze(Date.parse("2010-06-15"))
          @organization.gor_fiscal_year_start(:spend).should == [2008, 2009]
        end
      end
    end

    context "when type is budget" do
      context "when today is 2010-07-15" do
        it "start is 2010-07-01 and end is 2011-06-30" do
          Timecop.freeze(Date.parse("2010-07-15"))
          @organization.gor_fiscal_year_start(:budget).should == [2010, 2011]
        end
      end

      context "when today is 2010-06-15" do
        it "start is 2009-07-01 and end is 2010-06-30" do
          Timecop.freeze(Date.parse("2010-06-15"))
          @organization.gor_fiscal_year_start(:budget).should == [2009, 2010]
        end
      end
    end
  end
end
