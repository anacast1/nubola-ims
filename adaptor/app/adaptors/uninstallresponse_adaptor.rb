class UninstallresponseAdaptor < Adaptation::Adaptor
  
  def process uninstallresponse

    uninstallresponse.applications.each do |app|
      a = App.find_by_unique_app_id app.id
      i = Install.find(:first, :conditions => ["app_id=? and group_id=?", a.id, uninstallresponse.gid])
      status = app.status.code
      if status == "UNINSTALL_OK"
        i.destroy
      else
        i.update_attributes!(:status => "UNINSTALL_FAILED")
      end
    end

  end

end
