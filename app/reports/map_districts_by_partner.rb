require 'fastercsv'

class Reports::MapDistrictsByPartner
  include Reports::Helpers

  def initialize(type)
    if type == :budget
      @is_budget = true
    elsif type == :spent
      @is_budget = false
    else
      raise "Invalid type #{type}".to_yaml
    end

    partners = DataResponse.in_progress.map(&:responding_organization) +
      DataResponse.submitted.map(&:responding_organization)
    partners = partners.uniq

    @districts_hash = {}
    Location.all.each do |location|
      @districts_hash[location] = {}
      @districts_hash[location][:total] = 0
      @districts_hash[location][:partners] = {} # partner => amount
    end
    partners.each{|partner| set_district_hash_for_code(partner)}

    @csv_string = FasterCSV.generate do |csv|
      csv << build_header
      Location.all.each{|location| build_row(csv, location)}
    end
  end


  def csv
    @csv_string
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
      provider.provider_for.only_simple.canonical.each do |activity|
        code_assignments = @is_budget ?
          activity.budget_district_coding : activity.spend_district_coding
        code_assignments.each do |ca|
          amount = ca.calculated_amount * activity.toRWF
          loc = ca.code
          @districts_hash[loc][:total] += amount #TODO convert currency
          if @districts_hash[loc][:partners][provider]
            @districts_hash[loc][:partners][provider] += amount
          else
            @districts_hash[loc][:partners][provider] = amount unless amount == 0
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
