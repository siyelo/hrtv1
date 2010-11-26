require 'fastercsv'

class Reports::MapDistrictsByPartner < Reports::CodedActivityReport
  include Reports::Helpers
 

# location => partner, amount 
  def initialize(activities, report_type)
    @codes_to_include = []
  #  [9020101, 90207].each do |e|
  #    @codes_to_include << Nsp.find_by_external_id(e)
    partners_to_include = DataResponse.in_process.map(&:responding_organization) +
      DataResponse.submitted.map(&:responding_organization)
    partners_to_include = partners_to_include.uniq #just in case
      #[Organization.find_by_name("EGPAF"), Organization.find_by_name("CCHIPs")] #Org.all :joins => :provider_for
    partners_to_include.each do |e|
      @codes_to_include << e #if e.activities.count > 0
    end
    @districts_hash = {}
    Location.all.each do |l|
      @districts_hash[l] = {}
      @districts_hash[l][:total] = 0
      @districts_hash[l][:partner_amt] = {} # partner => amt
    end
#    @district_proportions_hash = {} # activity => {location => proportion}
    @csv_string = FasterCSV.generate do |csv|
      @activities = activities
      @report_type = report_type
      @codes_to_include.each do |c|
        set_district_hash_for_code c
      end

      csv << header()
      #raise @districts_hash.to_yaml
      Location.all.each do |l|
        row csv, l, @activities, @report_type
      end
    end
  end

  def set_district_hash_for_code code
    #code is provider
    provider = code
    #NOTE need to convert currencies and dynamic calcs not being used here 
    
    #cas = @report_type.with_activities(code.provider_for.only_simple.map(&:id))#.with_code_id(code.id)
    # or
    provider.provider_for.only_simple.canonical.each do |act|
      #act = Activity.find(1107) 
      cas = act.budget_district_coding if @report_type == CodingBudgetDistrict
      cas = act.spend_district_coding if @report_type == CodingSpendDistrict
      cas.each do |ca|
        amt = ca.calculated_amount * act.toRWF
        loc = ca.code
        @districts_hash[loc][:total] += amt #TODO convert currency
        unless @districts_hash[loc][:partner_amt][provider].nil?
          @districts_hash[loc][:partner_amt][provider] += amt
        else
          @districts_hash[loc][:partner_amt][provider] = amt unless amt == 0
        end
      end if cas
    end
  end

  def row(csv, loc, activities, report_type)
    #hierarchy = code_hierarchy(code)
    row = []
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
    row << "District"
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
