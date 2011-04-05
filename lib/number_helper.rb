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
                      :unit => "<span class=\"currency\">#{unit}</span>", 
                      :delimiter => ",", 
                      :format => "%n %u",
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
  
  def universal_currency_converter(amount, from, to)
    amount = 0 if amount.blank?
    rate = Money.default_bank.get_rate(from, to)
    unless rate
      if from == to
        rate = 1
      elsif !(Money.default_bank.get_rate(from, "USD").nil? || Money.default_bank.get_rate("USD", to).nil?)
        from_to_usd = Money.default_bank.get_rate(from, "USD") * amount
        amount = from_to_usd
        rate = Money.default_bank.get_rate("USD", to)
      else
        rate = 1
        to = from
      end
    end

    n2cnds(amount * rate, to)
  end

end
