module ActsAsStripper
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def acts_as_stripper
      include InstanceMethods
    end
  end

  module InstanceMethods
    def strip_non_decimal(number)
      number.gsub(/[^\d\.]/, '')
    end
  end
end

ActiveRecord::Base.send(:include, ActsAsStripper)