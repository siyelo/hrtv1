require 'fastercsv'

class Reports::ActivitiesByFullCoding < Reports::CodedActivityReport
  include Reports::Helpers
  
  def initialize(activities, report_type)
    @csv_string = FasterCSV.generate do |csv|
      csv << header()
      @activities = activities
      @report_type = report_type
      @leaves = Nsp.leaves
      Mtef.roots.reverse.each do |nsp_root|
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
    kids = code.children#.with_type("Nsp")
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
    #TODO merge cells[code.level:amount_column] for this code
  end

  def row(csv, code, activities, report_type)
    hierarchy = code_hierarchy(code)
    #TODO don't show code hierarchy / have it blank if less than 5
    # in this code
    # !!! OR offset by indentation since not showing all to the left
    # anymore
    cas = code.leaf_assigns_for_activities_for_code_set(report_type, @leaves, activities)
    cas.each do |assignment|
      if assignment.cached_amount
        activity = assignment.activity
        row = []
        row = hierarchy.clone
#        row << assignment.cached_amount / assignment.activity.budget
        row << n2c(assignment.cached_amount)
        #TODO bold the name in this below
        if activity.name.blank?
          row << activity.description.chomp
        else
          row << "#{activity.name.chomp} - #{activity.description.chomp}"
        end
#        row << "#{activity.start_date} - #{activity.end_date}"
        row << activity.spend_q1 ? 'x' : nil
        row << activity.spend_q2 ? 'x' : nil
        row << activity.spend_q3 ? 'x' : nil
        row << activity.spend_q4 ? 'x' : nil
        row << activity.locations.join(' | ')
        row << activity.provider.try(:short_name) if assignment.activity.provider
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
    row << "Code"
    (Code.deepest_nesting-1).times do |i|
      row << "Code"
    end
#    row << "% of Activity"
    row << "Budget"
    row << "Activity Description"
#    row << "Dates"
    row << "Q1"
    row << "Q2"
    row << "Q3"
    row << "Q4"
    row << "Districts"
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
    Code.each_with_level(code.self_and_ancestors) do |e, level| # each_with_level() is faster than level()
      if e==code
        hierarchy << official_name_w_sum(e)
      else
        hierarchy << nil
      end
      #hierarchy << "#{e.external_id} - #{e.sum_of_assignments_for_activities(@report_type, @activities)}"
    end
    (Code.deepest_nesting - hierarchy.size).times{ hierarchy << nil } #append empty columns if nested higher
    hierarchy
  end

  def official_name_w_sum code
    "#{code.official_name ? code.offical_name : code.short_display}" # - #{n2c( code.sum_of_assignments_for_activities(@report_type, @activities) )}"
  end

end
