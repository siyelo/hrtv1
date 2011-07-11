class OtherCost < Activity

  ### Constants
  FILE_UPLOAD_COLUMNS = %w[project_name description budget spend]

  def self.download_template
    FasterCSV.generate do |csv|
      csv << OtherCost::FILE_UPLOAD_COLUMNS
    end
  end

  # Overrides activity currency deletage method
  # some other costs does not have a project and
  # then we use the currency of the data response
  def currency
    project ? project.currency : data_response.currency
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
#  budget                                :integer(10)
#  spend_q1                              :integer(10)
#  spend_q2                              :integer(10)
#  spend_q3                              :integer(10)
#  spend_q4                              :integer(10)
#  start_date                            :date
#  end_date                              :date
#  spend                                 :integer(10)
#  text_for_provider                     :text
#  text_for_targets                      :text
#  text_for_beneficiaries                :text
#  spend_q4_prev                         :integer(10)
#  data_response_id                      :integer         indexed
#  activity_id                           :integer         indexed
#  budget_percentage                     :integer(10)
#  spend_percentage                      :integer(10)
#  approved                              :boolean
#  CodingBudget_amount                   :integer(10)     default(0)
#  CodingBudgetCostCategorization_amount :integer(10)     default(0)
#  CodingBudgetDistrict_amount           :integer(10)     default(0)
#  CodingSpend_amount                    :integer(10)     default(0)
#  CodingSpendCostCategorization_amount  :integer(10)     default(0)
#  CodingSpendDistrict_amount            :integer(10)     default(0)
#  budget_q1                             :integer(10)
#  budget_q2                             :integer(10)
#  budget_q3                             :integer(10)
#  budget_q4                             :integer(10)
#  budget_q4_prev                        :integer(10)
#  comments_count                        :integer         default(0)
#  sub_activities_count                  :integer         default(0)
#  spend_in_usd                          :integer(10)     default(0)
#  budget_in_usd                         :integer(10)     default(0)
#  project_id                            :integer
#  ServiceLevelBudget_amount             :integer(10)     default(0)
#  ServiceLevelSpend_amount              :integer(10)     default(0)
#  budget2                               :integer(10)
#  budget3                               :integer(10)
#  budget4                               :integer(10)
#  budget5                               :integer(10)
#

