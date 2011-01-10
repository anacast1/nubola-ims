class LoginAdaptor < ApplicationAdaptor
  
  def registra login
    user = User.find_by_login(login.id)
    group = Group.find_by_id(login.gid)
    Registre.create(:text => login.to_xml.to_s, :action => "login", :user => user, :group => group, :amount => login.total)
  end

end
