class LogoutAdaptor < ApplicationAdaptor
  
  def registra logout
    user = User.find_by_login(logout.id)
    group = Group.find_by_id(logout.gid)
    Registre.create(:text => logout.to_xml.to_s, :action => "logout", :user => user, :group => group, :amount => logout.total)
  end

end
