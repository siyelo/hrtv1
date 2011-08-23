module DateHelper
  def self.flexible_date_parse(date_string)
    begin
      Date.parse(date_string.gsub('/', '-'))
    rescue
      Date.strptime(date_string.gsub('/', '-'), '%d-%m-%Y') rescue date_string
    end
  end
end
