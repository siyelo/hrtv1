def change_type(id, new_type)
  code = Code.find_by_external_id(id)
  code.type = new_type
  code.save!
  puts "Changed type of code with id: #{code.id} from: #{code.type_was} to #{code.type}"
end

change_type("10502", 'Nha')
