module AutocreateHelper
  def assign_or_create_organization(id_or_name)
    if NumberHelper.is_number?(id_or_name)
      new_id = id_or_name
    else
      organization = Organization.find_or_create_by_name(id_or_name)
      organization.save(false) # ignore any errors e.g. on currency or contact details
      new_id = organization.id
    end
    new_id
  end
end
