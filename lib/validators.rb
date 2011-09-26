module ActiveRecord
  module Validations
    module ClassMethods

      def validates_dates_order(start_date, end_date, options)
        configuration = { :on => :save } # run the validations on record save

        send(validation_method(configuration[:on]), configuration) do |record|
          if record.send(start_date).present? && record.send(end_date).present?
            record.errors.add(start_date, options[:message]) unless record.send(start_date) < record.send(end_date)
          end
        end
      end
    end
  end
end
