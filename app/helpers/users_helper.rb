module UsersHelper
  
  def available_roles
    roles = %w[reporter manager]
    roles = User::ROLES if current_user.sysadmin?
    roles.map{|u| [u.humanize, u]}
  end
end
