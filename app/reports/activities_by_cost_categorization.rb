require 'fastercsv'

class Reports::ActivitiesByCostCategorization
  include Reports::Helpers

  def initialize(type)
    @is_budget    = is_budget?(type)
    codes         = get_codes
    code_ids      = codes.map{|code| code.id}
    beneficiaries = get_beneficiaries

    @csv_string   = FasterCSV.generate do |csv|
      csv << build_header(beneficiaries, codes)

      root_activities.each do |activity|
        if activity.projects.empty?
          csv << build_row(activity, beneficiaries, code_ids, " ")
        else
          activity.projects.each do |project|
            csv << build_row(activity, beneficiaries, code_ids, "#{h project.name}")
          end
        end
      end
    end
  end

  def csv
    @csv_string
  end

  private

    def build_header(beneficiaries, codes)
      row = []

      #row << "funding_source"
      row << "project"
      row << "org.name"
      row << "org.type"
      row << "activity.id"
      row << "activity.name"
      row << "activity.description"
      beneficiaries.each{|beneficiary| row << "#{beneficiary}"}
      row << "activity.text_for_beneficiaries"
      row << "activity.text_for_targets"
      row << "activity.budget"
      row << "activity.spend"
      row << "currency"
      row << "activity.start"
      row << "activity.end"
      row << "activity.provider"
      codes.each{|code| row << "#{code.to_s_with_external_id}"}

      row
    end

    def build_row(activity, beneficiaries, code_ids, project_name)
      act_benefs = activity.beneficiaries.map{|code| code.short_display}
      if @is_budget
        code_assignments = activity.budget_cost_category_coding.map{|ca| ca.code_id}
      else
        code_assignments = activity.spend_cost_category_coding.map{|ca| ca.code_id}
      end
      row = []

      #row << get_funding_source_name(activity)
      row << project_name
      row << "#{h activity.organization.name}"
      row << "#{activity.organization.type}"
      row << "#{activity.id}"
      row << "#{h activity.name}"
      row << "#{h activity.description}"
      beneficiaries.each{|beneficiary| row << (act_benefs.include?(beneficiary) ? "yes" : " " )}
      row << "#{h activity.text_for_beneficiaries}"
      row << "#{h activity.text_for_targets}"
      row << "#{activity.budget}"
      row << "#{activity.spend}"
      row << "#{activity.data_response.currency}"
      row << "#{activity.start}"
      row << "#{activity.end}"
      row << provider_name(activity)
      code_ids.each{|code_id| row << get_code_assignment_value(activity, code_assignments, code_id)}

      row
    end

    def get_codes
      codes = []
      CostCategory.roots.each do |code|
        code.self_and_descendants.each do |code2|
          codes << code2
        end
      end
      codes
    end

    def get_code_assignment_value(activity, code_assignments, code_id)
      if code_assignments.include?(code_id)
        if @is_budget
          ca = CodingBudgetCostCategorization.find(:first, :conditions => {:activity_id => activity.id, :code_id => code_id})
        else
          ca = CodingSpendCostCategorization.find(:first, :conditions => {:activity_id => activity.id, :code_id => code_id})
        end
        ca ? ca.cached_amount : 0
      else
        nil
      end
    end
end
