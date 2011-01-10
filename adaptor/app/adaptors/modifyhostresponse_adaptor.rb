class ModifyhostresponseAdaptor < Adaptation::Adaptor
  
  def process modifyhostresponse
    h=Host.find_by_hostname modifyhostresponse.hostname
    status = modifyhostresponse.status.code
    if status == "MODIFYHOST_OK"
      h.status = "OK"
    else
      h.status = "MODIFYHOST_FAILED"
    end
    h.save!
  end

end
