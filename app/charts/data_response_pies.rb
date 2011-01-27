module Charts::DataResponsePies

  VIRTUAL_TYPES = [:budget_stratprog_coding, :spend_stratprog_coding,
   :budget_stratobj_coding, :spend_stratobj_coding]

  class << self
    def data_response_pie(data_response, codings_type = nil, code_type = nil)
      if VIRTUAL_TYPES.include?(codings_type.to_sym)
        get_virtual_codes(data_response, codings_type)
      else
        scope = Code.scoped({:conditions => ["data_responses.id = ?", data_response.id]})
        scope = scope.scoped({:conditions => ["code_assignments.type = ?", codings_type]}) if codings_type
        scope = scope.scoped({:conditions => ["codes.type = ?", code_type]}) if code_type
        codes = scope.find(:all,
              :select => "codes.id as code_id, codes.parent_id as parent_id, codes.short_display, codes.short_display AS name, SUM(code_assignments.cached_amount) AS value",
              :joins => {:code_assignments => {:activity => :data_response}},
              :group => "codes.short_display, codes.id, codes.parent_id",
              :order => 'value DESC')

        parent_ids = codes.collect{|n| n.parent_id} - [nil]
        parent_ids.uniq!

        # remove cached (parent) codes
        codes.reject{|ca| parent_ids.include?(ca.code_id)}
      end
    end

    def get_virtual_codes(data_response, virtual_type)
      codes = []
      assignments = data_response.activities.collect{|a| a.send(virtual_type)}.flatten
      assignments.group_by {|a| a.code}.each do |code, array|
        row = [code.short_display, array.inject(0) {|sum, v| sum + v.cached_amount}]
        def row.value
          self[1]
        end
        def row.name
          self[0]
        end
        codes << row
      end
      codes
    end
  end
end
