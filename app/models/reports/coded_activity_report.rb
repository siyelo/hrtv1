require 'fastercsv'

class Reports::CodedActivityReport < Reports::ActivityReport

  attr_accessor :codes, :code_ids, :get_codes_array_method, :code_id_method

  # TODO accept hash {codes :=> { code_ids, get_codes_array_method, code_id_method}
  def initialize(codes = nil, get_codes_array_method = nil, code_id_method = nil)
    #add to cols only when you are doing a row join, not column join
    #dont do chaining yet, just one set of codes
    # TODO add beneficiaries as first instance of codes

    @codes                  = codes
    @get_codes_array_method = get_codes_array_method
    @code_id_method         = code_id_method
    @code_ids               = codes.map(&:id)
  end

  protected

    def cache_activities(code_assignments)
      activities = {}
      code_assignments.each do |ca|
        activities[ca.activity] = {}
        sum_of_children = ca.sum_of_children.nil? ? 0 : ca.sum_of_children
        activities[ca.activity][:leaf_amount] = sum_of_children > 0 ? 0 : ca.cached_amount
        activities[ca.activity][:amount] = ca.cached_amount
      end
      activities
    end


    def build_header
      row = super
      codes.each do |code|
        row << (code.respond_to?(:to_s_with_external_id) ?
                "#{code.to_s_with_external_id}" : "#{code}")
      end

      row
    end

    # override for more complex behavior
    def get_codes_from_activity activity
      activity.send(get_codes_array_method)
    end

    def build_rows(activity)
      base_rows = super(activity)
      rows = []
  #    debugger if activity.class == SubActivity
      base_rows.each do |base_row|
        act_codes = get_codes_from_activity(activity).map(&code_id_method)
        row = []
        @code_ids.each do |code_id|
          if act_codes.include?(code_id)
            column_value = value_for_code_column activity, code_id
            row << column_value
          else
            row << " "
          end
        end
        rows << (base_row + row).flatten
      end

      rows
    end

    def value_for_code_column activity, code_id
      "yes"
      #you should implement this method
      #code = activity.send(get_codes_array_method).reject {|c| c.id=code_id}
      # or maybe
      #code = code_class.find code_id
      #unless ca.amount.nil?
      #  row << ca.amount
      #else
      #  row << "#{ca.percentage}%"
      #end
    end
end
