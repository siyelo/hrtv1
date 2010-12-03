Factory.define :sub_activity, :class => SubActivity do |f|
  f.name            { 'sub_activity_name' }
  f.description     { 'sub_activity_description' }
  f.budget          { 5000000.00 }
  f.activity        { Factory.create :activity }
  f.data_response   { Factory.create(:data_response) }
end
