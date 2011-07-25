require 'fastercsv'

class Reports::MapDistrictsByPartner
  include Reports::Helpers

  def initialize(type, request)
    @is_budget = is_budget?(type)
    # partners   = DataResponse.in_progress.map(&:organization) +
    #            DataResponse.submitted.map(&:organization)
    partners   = Organization.with_in_progress_responses_for(request) + 
                 Organization.with_submitted_responses_for(request)
    partners   = partners.uniq

    @districts_hash = {}
    Location.all.each do |location|
      @districts_hash[location] = {}
      @districts_hash[location][:total] = 0
      @districts_hash[location][:partners] = {} # partner => amount
    end

    partners.each{|partner| set_district_hash_for_code(partner)}
  end


  def csv
    FasterCSV.generate do |csv|
      csv << build_header
      Location.all.each{|location| build_row(csv, location)}
    end
  end

  private
    def build_header
      row = []

      row << "District"
      row << "Total Budget"
      row << "1st Development Partner by Amount"
      row << "Amount"
      row << "All DP's"
      max_partners_length.times do |i| #for one with most partners
        row << "#{i+2} DP by Amount"
        row << "#{i+2} Amount"
      end

      row
    end

    def set_district_hash_for_code(provider)
      activities = provider.provider_for.only_simple.canonical
      preload_district_associations(activities, @is_budget) # eager-load
      activities.each do |activity|
        code_assignments = @is_budget ?
          activity.budget_district_coding_adjusted : activity.spend_district_coding_adjusted
        code_assignments.each do |ca|
          amount = ca.cached_amount_in_usd
          location = ca.code
          @districts_hash[location][:total] += amount
          if @districts_hash[location][:partners][provider]
            @districts_hash[location][:partners][provider] += amount
          else
            @districts_hash[location][:partners][provider] = amount unless amount == 0
          end
        end if code_assignments
      end
    end

    def build_row(csv, location)
      row = []

      row << location.to_s.upcase
      row << n2c(@districts_hash[location].delete(:total)) #remove key

      add_partners(row, location)

      csv <<  row
    end

    def max_partners_length
      @districts_hash.map{|k,v| v[:partners]}.map{|partner| partner.size}.max - 1
    end

    # TODO: refactor - duplicate method
    def add_partners(row, location)
      partners = @districts_hash[location][:partners]

      if partners.present?
        sorted_partners = sort_partners(partners)
        top_partner     = sorted_partners.first

        row << top_partner[0].to_s
        row << n2c(top_partner[1])
        row << full_partners_list(sorted_partners)

        sorted_partners.shift # dont show top_partner again
        sorted_partners.each do |partner|
          row << partner[0].to_s
          row << n2c(partner[1])
        end
      end
    end

    def sort_partners(partners)
      partners.sort{|a,b| b[1] <=> a[1]} #sort by value, desc
    end

    def full_partners_list(sorted_partners)
      sorted_partners.map{|partner| "#{partner[0].to_s}(#{n2c(partner[1])})"}.join(",")
    end
end
