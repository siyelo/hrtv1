module ReportsControllerHelpers

  private
    def report_name
      "#{params[:id]}.csv"
    end
end
