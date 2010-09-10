require 'fastercsv'

class Reports::UsersByOrganization

  def initialize
    @csv_string = FasterCSV.generate do |csv|
      csv << build_header

      #print data
      User.find(:all, :include => :organization).each do |u|
        csv << build_row(u)
      end
    end
  end

  def csv
    @csv_string
  end

  protected

  def h(str)
    if str
      str.gsub!(',', '  ')
      str.gsub!("\n", '  ')
      str.gsub!("\t", '  ')
      str.gsub!("\015", "  ") # damn you ^M
    end
    str
  end

  def build_header
    [ "user.username", "user.email", "user.full_name", "organization.name", "organization.type" ]
  end

  def build_row(user)
    [ "#{h user.username}", "#{h user.email}", "#{h user.full_name}", "#{h user.organization.try(:name)}", "#{user.organization.try(:type)}" ]
  end
end

