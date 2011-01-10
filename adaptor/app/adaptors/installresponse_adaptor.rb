class InstallresponseAdaptor < Adaptation::Adaptor
  
  def process installresponse

    installresponse.applications.each do |app|

      a = App.find_by_unique_app_id app.id
      i = Install.find(:first, :conditions => ["app_id=? and group_id=?", a.id, installresponse.gid])
      status = app.status.code
      if status == "INSTALL_OK"
        i.status = "OK"
        if installresponse.original_host != installresponse.host
          # si els usuaris estàn loginats enviem un missatge de
          # login xque la seva app els vegi també loginats a la màquina.
          users = User.find_all_by_group_id(installresponse.gid)
          users.each do |user|
            us = Session.find_by_login(user.login)
            unless us.nil?
              login     = Login.new
              login.id  = us.login
              login.gid = installresponse.gid
              login.sid = us.sessid
              publish login 
            end
          end
        end
      else
        i.status = "INSTALL_FAILED"
      end
      i.save!

    end

  end

end
