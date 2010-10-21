class DataElement < ActiveRecord::Base
  
  belongs_to :data_response
  belongs_to :data_elementable, :polymorphic => true

end

# == Schema Information
#
# Table name: data_elements
#
#  id                    :integer         primary key
#  data_response_id      :integer         indexed
#  data_elementable_id   :integer         indexed
#  data_elementable_type :string(255)     indexed
#

