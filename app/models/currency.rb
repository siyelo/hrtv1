class Currency < ActiveRecord::Base
end

# == Schema Information
#
# Table name: currencies
#
#  id         :integer         not null, primary key
#  conversion :string(255)
#  rate       :float
#  created_at :datetime
#  updated_at :datetime
#

