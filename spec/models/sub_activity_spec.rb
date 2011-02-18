require File.dirname(__FILE__) + '/../spec_helper'

describe SubActivity do

  describe "creating a record" do
    subject { Factory(:sub_activity) }

    it { should be_valid }
    it { should belong_to :activity }
    #TODO
  end

  describe "code_assignments" do
    #it "should return code_assignments" do
      #project        = Factory.create(:project)
      #donor          = Factory.create(:organization, :type => 'Donor',
                                      #:name => 'Donor')
      #implementer1   = Factory.create(:organization, :type => 'Other',
                                      #:name => 'Implementer 1')
      #implementer2   = Factory.create(:organization, :type => 'Other',
                                      #:name => 'Implementer 2')
      #ngo            = Factory.create(:organization, :type => 'Ngo',
                                      #:name => 'Ngo')
      #data_request   = Factory.create(:data_request, :organization => donor)
      #data_response  = Factory.create(:data_response, :organization => ngo,
                                      #:data_request => data_request)
      ##funding_source = Factory.create(:funding_source, :data_response => data_response,
                                      ##:from => donor, :to => donor)
      ##p funding_source
      ##Factory.create(:activity, :name => 'Activity 1')
    #end
  end
end

# == Schema Information
#
# Table name: activities
#
#  id                                    :integer         primary key
#  name                                  :string(255)
#  created_at                            :timestamp
#  updated_at                            :timestamp
#  provider_id                           :integer
#  description                           :text
#  type                                  :string(255)
#  budget                                :decimal(, )
#  spend_q1                              :decimal(, )
#  spend_q2                              :decimal(, )
#  spend_q3                              :decimal(, )
#  spend_q4                              :decimal(, )
#  start                                 :date
#  end                                   :date
#  spend                                 :decimal(, )
#  text_for_provider                     :text
#  text_for_targets                      :text
#  text_for_beneficiaries                :text
#  spend_q4_prev                         :decimal(, )
#  data_response_id                      :integer
#  activity_id                           :integer
#  budget_percentage                     :decimal(, )
#  spend_percentage                      :decimal(, )
#  approved                              :boolean
#  CodingBudget_amount                   :decimal(, )     default(0.0)
#  CodingBudgetCostCategorization_amount :decimal(, )     default(0.0)
#  CodingBudgetDistrict_amount           :decimal(, )     default(0.0)
#  CodingSpend_amount                    :decimal(, )     default(0.0)
#  CodingSpendCostCategorization_amount  :decimal(, )     default(0.0)
#  CodingSpendDistrict_amount            :decimal(, )     default(0.0)
#  budget_q1                             :decimal(, )
#  budget_q2                             :decimal(, )
#  budget_q3                             :decimal(, )
#  budget_q4                             :decimal(, )
#  budget_q4_prev                        :decimal(, )
#  comments_count                        :integer         default(0)
#  sub_activities_count                  :integer         default(0)
#  spend_in_usd                          :decimal(, )     default(0.0)
#  budget_in_usd                         :decimal(, )     default(0.0)
#

