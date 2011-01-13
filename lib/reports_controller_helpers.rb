module ReportsControllerHelpers
  TYPE_MAP = {'budget' => CodingBudget, 'spend' => CodingSpend}

  private
    def get_report_type(type)
      TYPE_MAP[type] || CodingBudget
    end

    def send_csv(text, filename)
      send_data text,
                :type => 'text/csv; charset=iso-8859-1; header=present',
                :disposition => "attachment; filename=#{filename}"
    end
end
