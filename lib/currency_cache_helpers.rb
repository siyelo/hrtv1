module CurrencyCacheHelpers
  private
    def update_cached_currency_amounts
      if self.currency_changed?
        self.activities.each do |a|
          a.code_assignments.each {|c| c.save}
          a.save
        end
      end
    end
end
