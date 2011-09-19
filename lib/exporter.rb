# Exporting files (via controller actions)
module Exporter
  def send_csv(data, filename)
    send_file(data, filename, "text/csv; charset=iso-8859-1; header=present")
  end

  def send_xls(data, filename)
    send_file(data, filename, "application/excel")
  end

  def send_file(data, filename, type = "text/csv; charset=iso-8859-1; header=present")
    send_data data, :type => type,
              :disposition=>"attachment; filename=#{filename}"
  end
end