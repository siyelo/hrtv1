require 'fastercsv'

class Reports::ActivitiesByDistricts
  include Reports::Helpers

  def initialize(type, request)
    @is_budget     = is_budget?(type)
    @coding_class  = @is_budget ? CodingBudgetDistrict : CodingSpendDistrict
    @codes         = get_codes
    @code_ids      = @codes.map{|code| code.id}
    @beneficiaries = get_beneficiaries
    @request       = request
  end

  def csv
    FasterCSV.generate do |csv|
      csv << build_header
      root_activities(@request).each{|activity| csv << build_row(activity)}
    end
  end

  private

    def build_header
      row = []

      row << "funding_source"
      row << "project"
      row << "org.name"
      row << "org.type"
      row << "activity.id"
      row << "activity.name"
      row << "activity.description"
      @beneficiaries.each{|beneficiary| row << "#{beneficiary}"}
      row << "activity.text_for_beneficiaries"
      row << "activity.targets"
      row << "activity.budget"
      row << "activity.expenditure"
      row << "currency"
      row << "activity.start_date"
      row << "activity.end_date"
      row << "activity.provider"
      @codes.each{|code| row << "#{code.short_display}"}

      row
    end

    def build_row(activity)
      act_benefs = activity.beneficiaries.map{|code| code.short_display}
      if @is_budget
        code_assignments = activity.budget_district_coding_adjusted.map(&:code_id)
      else
        code_assignments = activity.spend_district_coding_adjusted.map(&:code_id)
      end
      row = []

      row << funding_source_name(activity)
      row << activity.project.try(:name)
      row << "#{h activity.organization.name}"
      row << "#{activity.organization.raw_type}"
      row << "#{activity.id}"
      row << "#{h activity.name}"
      row << "#{h activity.description}"
      @beneficiaries.each{|beneficiary| row << (act_benefs.include?(beneficiary) ? "yes" : " " )}
      row << "#{h activity.text_for_beneficiaries}"
      row << "#{h activity.targets.map{|o| o.description}.join('; ')}"
      row << "#{activity.budget_in_usd}"
      row << "#{activity.spend_in_usd}"
      row << "#{activity.data_response.currency}"
      row << "#{activity.start_date}"
      row << "#{activity.end_date}"
      row << provider_name(activity)
      @code_ids.each{|code_id| row << get_code_assignment_value(activity, code_assignments, code_id)}

      row
    end

    def get_codes
      Location.all
    end

    def get_code_assignment_value(activity, code_assignments, code_id)
      if code_assignments.include?(code_id)
        ca = @coding_class.find(:first, :conditions => {:activity_id => activity.id, :code_id => code_id})
        ca ? ca.cached_amount_in_usd : 0
      else
        nil
      end
    end
end

