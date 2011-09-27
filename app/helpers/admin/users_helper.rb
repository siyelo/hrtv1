module Admin::UsersHelper
  def last_signin_for(user)
    last = user.last_signin_at
    last.nil? ? 'never' : last.strftime('%d %b \'%y %H:%M')
  end
end
