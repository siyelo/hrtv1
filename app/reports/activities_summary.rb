require 'fastercsv'

class Reports::ActivitiesSummary
  include Reports::Helpers

  def initialize(request)
    @request = request
  end

  def csv
    FasterCSV.generate do |csv|
      csv << build_header

      #
      # NOTE: can't eager load :projects association because
      # sub_activity delegates it to activity and there is some problem
      #
      #Activity.find(:all, :conditions => ['id IN (?)', [4760]]).each do |activity| # DEBUG ONLY
      #Activity.find(:all, :conditions => ['id IN (?)', [1416]]).each do |activity| # DEBUG ONLY
      Activity.find(:all, :include => :provider).each do |activity|
        if ((activity.class == Activity && activity.sub_activities.empty?) ||
            activity.class == SubActivity) && activity.data_request == @request
          csv << build_row(activity)
        end
      end
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
      row << "activity.budget"
      row << "activity.spend"
      row << "currency"
      row << "activity.provider"
      row << "activity.provider.FOSAID"
      row << "activity.text_for_beneficiaries"
      row << "activity.text_for_targets"
      row << "Is Implementer?"
      row << "parent_activity.total_budget"
      row << "parent_activity.total_spend"

      row
    end

    def build_row(activity)
      organization  = activity.data_response.organization
      #TODO handle implementers correctly

      row = []

      row << funding_source_name(activity)
      row << activity.project.try(:name)
      row << "#{h organization.name}"
      row << "#{organization.raw_type}"
      row << "#{activity.id}"
      row << "#{h activity.name}"
      row << "#{h activity.description}"
      row << "#{activity.budget_in_usd}"
      row << "#{activity.spend_in_usd}"
      row << "#{activity.currency}"
      row << provider_name(activity)
      row << provider_fosaid(activity)
      row << "#{h activity.text_for_beneficiaries}"
      row << "#{h activity.text_for_targets}"
      row << is_activity(activity)
      row << parent_activity_budget(activity)
      row << parent_activity_spend(activity)

      row
    end

end
