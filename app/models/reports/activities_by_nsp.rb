require 'fastercsv'

class Reports::ActivitiesByNsp < Reports::CodedActivityReport
  include Reports::Helpers
  
  def initialize(activities, report_type, show_respondent = false)
    @show_respondent = show_respondent
    @csv_string = FasterCSV.generate do |csv|
      csv << header()
      @activities = activities
      @report_type = report_type
      @leaves = Nsp.leaves
      Nsp.roots.reverse.each do |nsp_root|
        add_rows csv, nsp_root
      end
    end
  end

  def csv
    @csv_string
  end

  def add_rows csv, code
    add_code_summary_row(csv, code)
    row(csv, code, @activities, @report_type)
    kids = code.children.with_type("Nsp")
    kids.each do |c|
      add_rows(csv, c)
    end
  end

  def add_code_summary_row csv, code
#    csv << "In NSP #{code.short_display} #{code.id} #{code.external_id} "
#    csv << code.external_id.to_s
    total_for_code = code.sum_of_assignments_for_activities(@report_type, @activities)
    if total_for_code > 0
      csv << (code_hierarchy(code) + [nil,nil, "Total Budget - "+n2c(total_for_code)]) #put total in Q1 column
    end
  end

  def row(csv, code, activities, report_type)
    hierarchy = code_hierarchy(code)
    cas = code.leaf_assigns_for_activities(report_type,activities)
    cas.each do |assignment|
      if assignment.cached_amount
        activity = assignment.activity
        row = []
        row = hierarchy.clone
        row << n2c(assignment.cached_amount)
        if activity.name.blank?
          unless activity.description.nil?
            row << activity.description.chomp
          else
            row << nil
          end
        else
          val = "#{activity.name.chomp}"
          val += " - #{activity.description.chomp}" unless activity.description.nil?
          row << val
        end
        row << activity.spend_q1 ? 'x' : nil
        row << activity.spend_q2 ? 'x' : nil
        row << activity.spend_q3 ? 'x' : nil
        row << activity.spend_q4 ? 'x' : nil
        row << activity.locations.join(' | ')
        row << activity.data_response.responding_organization.try(:short_name) if @show_respondent
        if assignment.activity.provider
          row << activity.provider.try(:short_name) 
        else
          row << "No Implementer Specified"
        end
        row << activity.organizations.join(' | ')
        unless activity.sub_activities.implemented_by_health_centers.empty?
          row << activity.sub_activities.implemented_by_health_centers.count
        else
          row << nil
        end
        row << activity.beneficiaries.join(' | ')
        row << activity.id
        csv <<  row
      end
    end
  end

  def header()
    row = []
    row << "NSP Code"
    (Nsp.deepest_nesting-1).times do |i|
      row << "NSP Code"
    end
    row << "Budget"
    row << "Activity Description"
    row << "Q1"
    row << "Q2"
    row << "Q3"
    row << "Q4"
    row << "Districts"
    row << "Data Source" if @show_respondent
    row << "Implementer"
    row << "Institutions Assisted"
    row << "# of HC's Sub-implementing"
    row << "Beneficiaries"
    row << "ID"
    row
  end

  protected

  def code_hierarchy(code)
    # TODO merge all columns to the left and put row's value
    # if there is more than 5 rows in the section
    hierarchy = []
    Nsp.each_with_level(code.self_and_nsp_ancestors) do |e, level|
      if e==code
        hierarchy << official_name_w_sum(e)
      else
        hierarchy << nil
      end
      #hierarchy << "#{e.external_id} - #{e.sum_of_assignments_for_activities(@report_type, @activities)}"
    end
    (Nsp.deepest_nesting - hierarchy.size).times{ hierarchy << nil } #append empty columns if nested higher
    hierarchy
  end

  def official_name_w_sum code
    "#{code.official_name ? code.official_name : code.short_display}"
  end

end
