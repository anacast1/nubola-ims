class AdduserresponseAdaptor < ApplicationAdaptor
  
  def process adduserresponse

    adduserresponse.applications.each do |app|

      a = App.find_by_unique_app_id app.id
      if a
        u = User.find_by_login adduserresponse.id
        b = Bind.find(:first, :conditions => ["app_id = ? and user_id = ?", a.id, u.id])
        status = app.status.code
        if status == "ADDUSER_OK"
          b.status = "OK"

          # si l'usuari està loginat enviem un missatge de
          # login xque la seva nova app el vegi també loginat.
          us = Session.find_by_login(u.login)
          unless us.nil?
            login = Login.new
            login.id = u.login
            login.gid = u.group.id
            login.sid = us.sessid
            publish login 
          end

        else
          b.status = "ADDUSER_FAILED"
        end
        b.save! 
      end

    end

  end

end
