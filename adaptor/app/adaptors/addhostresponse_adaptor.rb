class AddhostresponseAdaptor < ApplicationAdaptor

  def process addhostresponse
    h=Host.find_by_hostname addhostresponse.hostname
    status = addhostresponse.status.code
    if status == "ADDHOST_OK"
      h.status = "OK"
      # si els usuaris estàn loginats enviem un missatge de
      # login xque la seva nova màquina els vegi també loginats.
      users = User.find_all_by_group_id(addhostresponse.gid)
      users.each do |user|
        us = Session.find_by_login(user.login)
        unless us.nil?
          login     = Login.new
          login.id  = us.login
          login.gid = addhostresponse.gid
          login.sid = us.sessid
          publish login 
        end
      end
    else
      h.status = "ADDHOST_FAILED"
    end
    h.save!
    
    registra addhostresponse
  end

end



