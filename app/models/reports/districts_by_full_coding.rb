require 'fastercsv'

class Reports::DistrictsByFullCoding < Reports::CodedActivityReport
  include Reports::Helpers
  
  def initialize(activities, report_type)
    @codes_to_include = []
    Code.all.each do |e|
      @codes_to_include << e if ["Mtef", "Nha", "Nsp", "Nasa"].include?(e.type.to_s)
    end
    @districts_hash = {}
    @codes_to_include.each do |c|
      @districts_hash[c] = {}
      @districts_hash[c][:total] = 0
      Location.all.each do |l|
        @districts_hash[c][l] = 0
      end
    end
    @district_proportions_hash = {} # activity => {location => proportion}
    @csv_string = FasterCSV.generate do |csv|
      csv << header()
      @activities = activities
      @report_type = report_type
      @leaves = Nsp.leaves
      Mtef.roots.each do |nsp_root|
        add_rows csv, nsp_root
      end
    end
  end

  def csv
    @csv_string
  end

  def add_rows csv, code
    add_code_summary_row(csv, code)
    row(csv, code, @activities, @report_type) if @districts_hash.key? code
    kids = code.children
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
    if @codes_to_include.include? code
      set_district_hash_for_code code
    end
  end

  def set_district_hash_for_code code
    # I didn't know that when you take a super class, when you get instances of the class,
    # they are of the type you called the named_scopes on, even though they have a different type
    # TODO there are hidden bugs potentially all over the place where we find CodeAssignment.with_type !
    # argh!
    # cas = CodeAssignment.with_activities(@activities.map(&:id)).with_code_id(code.id).with_type(@report_type)
    cas = @report_type.with_activities(@activities.map(&:id)).with_code_id(code.id)
    activities = {}
    cas.each{ |ca|
      activities[ca.activity] = {}
      activities[ca.activity][:leaf_amount] = ca.sum_of_children > 0 ? 0 : ca.cached_amount
      activities[ca.activity][:amount] = ca.cached_amount
    }
    activities.each do |a, h|
      if @district_proportions_hash.key? a
        #have cached values, so speed up these proportions
        @district_proportions_hash[a].each do |loc, proportion|
          @districts_hash[code][:total] += h[:leaf_amount] * proportion
          @districts_hash[code][loc] += h[:amount] * proportion
        end
      else
        @district_proportions_hash[a] = {}
        # We've got non-report type report type hard coding here
        # so it uses budgets
        a.budget_district_coding.each do |bd|
          #old buggy division when budget nil
          # proportion = bd.cached_amount / a.budget
          # new hot CodeAssignment instance method
          proportion = bd.proportion_of_activity
          loc = bd.code
          @district_proportions_hash[a][loc] = proportion
          @districts_hash[code][:total] += h[:leaf_amount] * proportion
          @districts_hash[code][loc] += h[:amount] * proportion
        end
      end
    end
  end

  def row(csv, code, activities, report_type)
    hierarchy = code_hierarchy(code)
    location_to_amount_for_code = @districts_hash[code]
    location_to_amount_for_code.each do |loc, amt|
      if amt != 0 and loc != :total
        row = []
        row = hierarchy.clone
        row << loc.to_s.upcase
        row << n2c(amt)
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
    row << "District"
    row << "Budget"
    row
  end

  protected

  def code_hierarchy(code)
    hierarchy = []
    Code.each_with_level(code.self_and_ancestors) do |e, level|
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
    "#{code.official_name ? code.official_name : code.short_display}"
  end

end
