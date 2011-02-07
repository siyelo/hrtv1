class Donor < Organization 
end



# == Schema Information
#
# Table name: organizations
#
#  id             :integer         not null, primary key
#  name           :string(255)
#  type           :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  raw_type       :string(255)
#  fosaid         :string(255)
#  users_count    :integer         default(0)
#  comments_count :integer         default(0)
#

