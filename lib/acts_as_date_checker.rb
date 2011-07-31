# Dependent on validates_date_time gem
module ActsAsDateChecker
  private
    def string_validator
      ActiveRecord::ConnectionAdapters::Column
    end
end
