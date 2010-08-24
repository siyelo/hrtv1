# == Schema Information
#
# Table name: organizations
#
#  id         :integer         primary key
#  name       :string(255)
#  type       :string(255)
#  created_at :timestamp
#  updated_at :timestamp
#  raw_type   :string(255)
#

class Ngo < Organization 
end
