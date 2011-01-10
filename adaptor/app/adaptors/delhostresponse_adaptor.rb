class DelhostresponseAdaptor < Adaptation::Adaptor
  
  def process delhostresponse
    h = Host.find_by_hostname delhostresponse.hostname
    if delhostresponse.status.code == "DELHOST_OK"
      #TODO: cuando se borra un host no se cobrara la parte
      # proporcional del tiempo que se ha tenido instalado
      # durante ese mes. Podria existir un estado "DELETED"
      # o retardar el destroy hasta el mes siguiente
      h.destroy
    else
      h.update_attributes(:status => "DELETEHOST_FAILED")
    end
  end

end
