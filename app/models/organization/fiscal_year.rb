module Organization::FiscalYear

  USG_START_MONTH = 10
  GOR_START_MONTH = 7

  # exception for invalid fiscal year type
  class InvalidFiscalYearType < StandardError; end

  def usg?
    fiscal_year_start_date? && fiscal_year_start_date.month == USG_START_MONTH
  end

  def gor?
    fiscal_year_start_date? && fiscal_year_start_date.month == GOR_START_MONTH
  end

  def quarter_label(type, quarter)
    start_year, end_year = gor_fiscal_year_start(type).map{ |y| y.to_s.last(2) }

    if usg?
      usg_quarter_label(quarter, start_year, end_year)
    else
      # NOTE: if fiscal year start date is wrong it will display GOR quarters
      gor_quarter_label(quarter, start_year, end_year)
    end
  end

  # NOTE: organizations reporting in USG FY will use GOR FY
  def gor_fiscal_year_start(type)
    raise InvalidFiscalYearType unless [:spend, :budget].include?(type)

    today = Date.today
    start_year = today.month < 7 ? today.year - 1 : today.year

    start_year -= 1 if type == :spend

    [start_year, start_year + 1]
  end

  private
    def usg_quarter_label(quarter, start_year, end_year)
      case quarter
      when "q4_prev": "Jul '#{start_year} - Sep '#{start_year}"
      when "q1"     : "Oct '#{start_year} - Dec '#{start_year}"
      when "q2"     : "Jan '#{end_year} - Mar '#{end_year}"
      when "q3"     : "Apr '#{end_year} - Jun '#{end_year}"
      when "q4"     : "Jul '#{end_year} - Sep '#{end_year}"
      end
    end

    def gor_quarter_label(quarter, start_year, end_year)
      case quarter
      when "q4_prev": "Apr '#{start_year} - Jun '#{start_year}"
      when "q1"     : "Jul '#{start_year} - Sep '#{start_year}"
      when "q2"     : "Oct '#{start_year} - Dec '#{start_year}"
      when "q3"     : "Jan '#{end_year} - Mar '#{end_year}"
      when "q4"     : "Apr '#{end_year} - Jun '#{end_year}"
      end
    end
end
