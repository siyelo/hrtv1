require 'fastercsv'

class Reports::MapFacilitiesByPartner < Reports::CodedActivityReport
  include Reports::Helpers
 

# location => partner, amount 
  def initialize(activities, report_type)
    @codes_to_include = []
    facilities_to_include =  Organization.all(:conditions => ["fosaid is not null"])
#[Organization.find_by_name("Muhima HD District Hospital | Nyarugenge"), Organization.find_by_name("CHK/CHUK National Hospital | Nyarugenge")]
    facilities_to_include.each do |e|
      @codes_to_include << e #if e.activities.count > 0
    end
    @districts_hash = {}
    facilities_to_include.each do |l|
      @districts_hash[l] = {}
      @districts_hash[l][:total] = 0 
      @districts_hash[l][:partner_amt] = {} # partner => amt
    end
#    @district_proportions_hash = {} # activity => {location => proportion}
    @csv_string = FasterCSV.generate do |csv|
      @activities = activities
      @report_type = report_type.constantize
      @codes_to_include.each do |c|
        set_district_hash_for_code c
      end

      csv << header()
      #raise @districts_hash.to_yaml
      @codes_to_include.each do |l|
        row csv, l, @activities, @report_type
      end
    end
  end

  def set_district_hash_for_code code
    #code is facility
    facility = code

    #if have my own DR, pull lots of info from there
    # otherwise get who gives me money by activities
    unless !facility.data_responses.last.empty?
      facility.provider_for.canonical.each do |act|
        #act = Activity.find(1107) 
        amt = act.budget if @report_type == CodingBudgetDistrict
        amt = act.spend if @report_type == CodingSpendDistrict
        amt = 0 if amt.nil?
        amt = amt * act.toRWF
        loc = facility
        partner = act.data_response.responding_organization
        adjust_partner_value_in_hash(loc, partner, amt)
      end
    else # i have a non empty data response
      dr = facility.data_responses.last #this will break in the future, but its okay ish with it being last
      facility.in_flows.all(:conditions => ["data_response_id = ?", dr.id]).each do |flow|
        amt = flow.budget if @report_type == CodingBudgetDistrict
        amt = flow.spend if @report_type == CodingSpendDistrict
        amt = 0 if amt.nil?
        amt = amt * flow.toRWF
        loc = facility
        partner = flow.from
        adjust_partner_value_in_hash(loc, partner, amt)
      end
    end
  end

  def adjust_partner_value_in_hash(loc, partner, amt)
    @districts_hash[loc][:total] += amt
    unless @districts_hash[loc][:partner_amt][partner].nil?
      @districts_hash[loc][:partner_amt][partner] += amt
    else
      @districts_hash[loc][:partner_amt][partner] = amt unless amt == 0
    end
  end

  def row(csv, loc, activities, report_type)
    #hierarchy = code_hierarchy(code)
    row = []
    row << loc.fosaid
    row << loc.locations.last.to_s
    row << loc.to_s.upcase
    row << n2c(@districts_hash[loc].delete(:total)) #remove key
    code_to_amt = @districts_hash[loc][:partner_amt]
    unless code_to_amt.size == 0
      sorted_code_amt = code_to_amt.sort{|a,b| b[1]<=>a[1]} #sort by value, desc
      # show top one
      top = sorted_code_amt.first
      row << top[0].to_s
      row << n2c(top[1])
   
      # show full list
      row << sorted_code_amt.collect{|e| "#{e[0].to_s}(#{n2c(e[1])})"}.join(",")
  
      sorted_code_amt.shift #dont show top again
      # show in cols
      # after sorting by amt
      sorted_code_amt.each do |e|
        row << e[0].to_s
        row << n2c(e[1])
      end
    end
    csv <<  row
  end

  def header()
    row = []
    row << "FOSAID"
    row << "District"
    row << "Facility Name"
    row << "Total Budget"
    row << "1st Development Partner by Amount"
    row << "Amount"
    row << "All DP's"
    (@districts_hash.collect{|k,v| v[:partner_amt]}.map(&:size).max - 1).times do |i| #for one with most partners
      row << "#{i+2} DP by Amount"
      row << "#{i+2} Amount"
    end
    row
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
#    total_for_code = code.sum_of_assignments_for_activities(@report_type, @activities)
#    if total_for_code > 0
#      csv << (code_hierarchy(code) + [nil,nil, "Total Budget - "+n2c(total_for_code)]) #put total in Q1 column
#    end
    #TODO merge cells[code.level:amount_column] for this code
  end

  # We've got non-report type report type hard coding here
  # so it uses budgets


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
    "#{code.official_name}" # - #{n2c( code.sum_of_assignments_for_activities(@report_type, @activities) )}"
  end

end
