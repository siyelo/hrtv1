class DataElement < ActiveRecord::Base
  
  belongs_to :data_response
  belongs_to :data_elementable, :polymorphic => true

end
