module ReportsControllerHelpers

  private

    def send_csv(text, filename)
      send_data text,
                :type => 'text/csv; charset=iso-8859-1; header=present',
                :disposition => "attachment; filename=#{filename}"
    end

    def report_name
      name = "#{params[:id]}"
      name += "_#{params[:type]}" if params[:type].present?
      name += ".csv"
      return name
    end
end
