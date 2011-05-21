module NumberHelper
  include ActionView::Helpers::NumberHelper

  def n2c(value, unit = "")
    number_to_currency(value,
                      :separator => ".",
                      :unit => unit,
                      :delimiter => ",")
  end

  def n2cs(value, unit = "")
    number_to_currency(value,
                      :separator => ".",
                      :unit => "<span class=\"currency\">#{unit}</span>",
                      :delimiter => ",",
                      :format => "%u %u")
  end

  def n2crs(value, unit = "")
    number_to_currency(value,
                      :separator => ".",
                      :unit => "<span class=\"currency\">#{unit}</span>",
                      :delimiter => ",",
                      :format => "%n %u")
  end

  def n2cr(value, unit = "")
    number_to_currency(value,
                      :separator => ".",
                      :unit => unit,
                      :delimiter => ",",
                      :format => "%n %u")
  end


  def n2cnd(value, unit = "")
    number_to_currency(value,
                       :separator => ".",
                       :unit => unit,
                       :delimiter => ",",
                       :format => "%u %n",
                       :precision => 0)
  end

  def n2cndr(value, unit = "")
    number_to_currency(value,
                       :separator => ".",
                       :unit => unit,
                       :delimiter => ",",
                       :format => "%n %u",
                       :precision => 0)
  end

  def n2cndrs(value, unit = "")
    number_to_currency(value,
                      :separator => ".",
                      :unit => "#{unit}",
                      :delimiter => ",",
                      :format => "<span class=\"amount\">%n</span> <span class=\"currency\">%u</span>",
                      :precision => 0)
  end

  def n2cnds(value, unit = "")
    number_to_currency(value,
                      :separator => ".",
                      :unit => "<span class=\"currency\">#{unit}</span>",
                      :delimiter => ",",
                      :format => "%u %n",
                      :precision => 0)
  end

  def currency_rate(from, to)
    if from == to || from.nil? || to.nil?
      1
    elsif (rate = Money.default_bank.get_rate(from, to))
      rate
    else
      to_usd   = Money.default_bank.get_rate(from, "USD")
      from_usd = Money.default_bank.get_rate("USD", to)

      to_usd && from_usd ? to_usd * from_usd : 1
    end
  end

  def universal_currency_converter(amount, from, to)
    amount = 0 if amount.blank?
    amount * currency_rate(from, to)
  end
end
