class OtherCost < Activity

  ### Constants
  FILE_UPLOAD_COLUMNS = %w[project_name description budget spend]

  ### Delegates
  delegate :currency, :to => :data_response, :allow_nil => true

  ### Class Methods

  def self.download_template
    FasterCSV.generate do |csv|
      csv << OtherCost::FILE_UPLOAD_COLUMNS
    end
  end

  def self.create_from_file(doc, data_response)
    saved, errors = 0, 0
    doc.each do |row|
      attributes = row.to_hash
      project = Project.find_by_name(attributes.delete('project_name'))
      attributes.merge!(:project_id => project.id) if project
      other_cost = data_response.other_costs.new(attributes)
      other_cost.save ? (saved += 1) : (errors += 1)
    end
    return saved, errors
  end

  ### Instance Methods

  # Overrides activity currency deletage method
  # some other costs does not have a project and
  # then we use the currency of the data response
  def currency
    project ? project.currency : data_response.currency
  end
end







# == Schema Information
#
# Table name: activities
#
#  id                                    :integer         not null, primary key
#  name                                  :string(255)
#  created_at                            :datetime
#  updated_at                            :datetime
#  provider_id                           :integer         indexed
#  description                           :text
#  type                                  :string(255)     indexed
#  budget                                :decimal(, )
#  spend_q1                              :decimal(, )
#  spend_q2                              :decimal(, )
#  spend_q3                              :decimal(, )
#  spend_q4                              :decimal(, )
#  start_date                            :date
#  end_date                              :date
#  spend                                 :decimal(, )
#  text_for_provider                     :text
#  text_for_targets                      :text
#  text_for_beneficiaries                :text
#  spend_q4_prev                         :decimal(, )
#  data_response_id                      :integer         indexed
#  activity_id                           :integer         indexed
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
#  project_id                            :integer
#  ServiceLevelBudget_amount             :decimal(, )     default(0.0)
#  ServiceLevelSpend_amount              :decimal(, )     default(0.0)
#  budget2                               :decimal(, )
#  budget3                               :decimal(, )
#  budget4                               :decimal(, )
#  budget5                               :decimal(, )
#  am_approved                           :boolean
#  user_id                               :integer
#  am_approved_date                      :date
#

