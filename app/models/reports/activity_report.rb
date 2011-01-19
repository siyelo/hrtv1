require 'fastercsv'

class Reports::ActivityReport
  include Reports::Helpers

  attr_accessor :query, :cols, :conditions, :joins

  def initialize options = {}
  end

  def csv
    unless @csv_string
      @csv_string = FasterCSV.generate do |csv|
        csv << build_header

        #Activity.find(:all, :conditions => ['id IN (?)', [4760]]).each do |a| # DEBUG ONLY
        Activity.all.each do |activity|
          if ((activity.class == Activity && activity.sub_activities.empty?) ||
              activity.class == SubActivity)
            csv << build_row(activity)
          end
        end
      end
    end
    @csv_string
  end

  protected

    def build_header
     row = []

     row << "project"
     row << "org.name"
     row << "org.type"
     row << "activity.id"
     row << "activity.name"
     row << "activity.description"
     row << "activity.budget"
     row << "activity.spend"
     row << "currency"
     row << "activity.start"
     row << "activity.end"
     row << "activity.provider"
     row << "activity.provider.FOSAID"
     row << "activity.text_for_beneficiaries"
     row << "activity.text_for_targets"
     row << "Is Sub Activity?"
     row << "parent_activity.total_budget"
     row << "parent_activity.total_spend"

     row
    end

    def build_row(activity)
      organization  = activity.data_response.responding_organization
      #TODO handle sub activities correctly

      row = []

      row << first_project(activity)
      row << "#{h organization.name}"
      row << "#{organization.type}"
      row << "#{activity.id}"
      row << "#{h activity.name}"
      row << "#{h activity.description}"
      row << "#{activity.budget}"
      row << "#{activity.spend}"
      row << "#{activity.currency}"
      row << "#{activity.start}"
      row << "#{activity.end}"
      row << provider_name(activity)
      row << provider_fosaid(activity)
      row << "#{h activity.text_for_beneficiaries}"
      row << "#{h activity.text_for_targets}"
      row << is_activity(activity)
      row << parent_activity_budget(activity)
      row << parent_activity_spend(activity)

      row
    end

  private

    def provider_name(activity)
      activity.provider ? "#{h activity.provider.name}" : " "
    end

    def provider_fosaid(activity)
      activity.provider ? "#{h activity.provider.fosaid}" : " "
    end

    def is_activity(activity)
      activity.class == SubActivity ? "yes" : ""
    end

    def parent_activity_budget(activity)
      activity.class == SubActivity ? activity.activity.budget : ""
    end

    def parent_activity_spend(activity)
      activity.class == SubActivity ? activity.activity.spend : ""
    end

    def first_project(activity)
      project = activity.projects.first
      project ? "#{h project.name}" : " "
    end
end
