class DeluserresponseAdaptor < ApplicationAdaptor
  
  def process deluserresponse

    deluserresponse.applications.each do |app|

      a = App.find_by_unique_app_id app.id
      if a
        u = User.find_by_login deluserresponse.id
        b = Bind.find(:first, :conditions => ["app_id = ? and user_id = ?", a.id, u.id])
        status = app.status.code
        if status == "DELUSER_OK"
          b.destroy
        else
          b.update_attributes!(:status => "DELUSER_FAILED")
        end
      end

    end
  
  end

end
