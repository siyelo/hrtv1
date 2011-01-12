require 'fastercsv'

class Reports::ActivityReport
  include Reports::Helpers

  attr_accessor :query, :cols, :conditions, :joins

  def initialize options = {}
  end

  def csv
    unless @csv_string
      @csv_string = FasterCSV.generate do |csv|
        csv << build_header()
        Activity.all.each do |a|
          if a.class == Activity && a.sub_activities.empty?
            rows = build_rows(a)
            add_rows_to_csv rows, csv
          elsif a.class == SubActivity
            rows = build_rows(a)
            add_rows_to_csv rows, csv
          end
        end
      end
    end
    @csv_string
  end

  protected

    def build_header
      header = []
      header << [ "project", "org.name", "org.type", "activity.id", "activity.name", "activity.description" ]
      header << ["activity.text_for_beneficiaries", "activity.budget", "activity.spend", "currency"]
      header << ["activity.start", "activity.end", "activity.provider", "activity.provider.FOSAID"]
      header << ["Is Sub Activity?", "parent_activity.total_budget", "parent_activity.total_spend"]
      header.flatten
    end

    def add_rows_to_csv rows, csv
      if rows.first.class == Array
        rows.each {|r| add_rows_to_csv r, csv}
      elsif rows.empty?
        #do nothing
      else
        csv << rows
      end
    end

    def build_rows(activity)
      rows=[]
      org        = activity.data_response.responding_organization
      #TODO handle sub activities correctly
      row = []
      row << [ "#{h org.name}", "#{org.type}", "#{activity.id}","#{h activity.name}", "#{h activity.description}" ]
      row << ["#{h activity.text_for_beneficiaries}",  "#{activity.budget}", "#{activity.spend}", "#{activity.currency}",  "#{activity.start}", "#{activity.end}" ]
      row << (activity.provider.nil? ? " " : "#{h activity.provider.name}" )
      row << (activity.provider.nil? ? " " : "#{h activity.provider.fosaid}" )
      if activity.class == SubActivity
        row << "yes"
        row << activity.activity.budget
        row << activity.activity.spend
      else
        row << ""
        row << ""
        row << ""
      end
      row.flatten
      if activity.projects.empty?
        row.unshift(" ")
        rows = [ row.flatten ]
      else
        activity.projects.each do |proj|
          proj_row = row.dup
          proj_row.unshift("#{h proj.name}")
          rows << proj_row.flatten
          break
        end
      end
      rows
    end

end
