require 'fastercsv'

class Reports::UsersByOrganization
  include Reports::Helpers

  def initialize(user = nil)
    @user = user
  end

  def csv
    FasterCSV.generate do |csv|
      csv << build_header
      users(@user).each{|user| csv << build_row(user)}
    end
  end

  private

    def build_header
      row = []

      row << "user.id"
      row << "user.email"
      row << "user.full_name"
      row << "organization.name"
      row << "organization.type"
      row << "data_response.status"

      row
    end

    def build_row(user)
      row = []

      row << user.id
      row << user.email
      row << user.full_name
      row << user.organization.try(:name)
      row << user.organization.try(:type)
      row << user.organization_status

      row
    end

    def users(user)
      if user
        User.find(:all, :conditions => ["users.organization_id = ?", user.organization_id])
      else
        User.find(:all, :include => :organization)
      end
    end
end

