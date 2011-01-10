module MessageSender

  def after_create
    @msg = xml4create # if @msg.nil?
    send_xml_message
  end

  def before_update
#    @lastmsg = xml4update # no n'hi ha prou
     @lastmsg = self.class.find_by_id(id).xml4update
#    if xml4update.split(" ").first.gsub("<", "") == "modifyhost"
#      @lastmsg = App.find_by_id(id).xml4update
#    elsif xml4update.split(" ").first.gsub("<", "") == "modifycontract" && (@lastmsg != @msg || @lastmsg.nil?)
#      @lastmsg = Contract.find_by_id(id).xml4update
#    end
#  rescue
  end

  def after_update
    @msg = xml4update # if @msg.nil?
    send_xml_message unless @lastmsg == @msg

#    if xml4update.split(" ").first.gsub("<", "") == "modifyhost"
#      if @lastmsg != @msg
#        @lastmsg = @msg
#        send_xml_message
#      end
#    elsif xml4update.split(" ").first.gsub("<", "") == "modifycontract"
#      if @lastmsg != @msg
#        @lastmsg = @msg
#        send_xml_message
#      end
#    else
#      @lastmsg = @msg
#      send_xml_message
#    end
#  rescue
  end

  # el cas del destroy es particular, no pot ser un callback perque el
  # destroy es fa al adaptor. S'ha de cridar aquest mètode a mà.
  # TODO: Posar un observer al status del model?
  def send_xml_for_destroy
    @msg = xml4destroy # if @msg.nil?
    send_xml_message
  end

  def send_xml_message(msg=nil)
    @msg = msg unless msg.nil?
    # guardamos el ultimo mensaje enviado, solo para poder comprobarlo en los test
    @messagesent = @msg
    r = system("#{Setting.oappublish} 'IMS' '#{@msg}'") rescue Mysql::Error
    if r 
      logger.info("\n\n[ SEND XML MESSAGE ]: #{@msg}\n\n")
    else
      logger.error("\n\n[ ERROR SENDING XML MESSAGE ]: #{@msg}\n\n")
    end
    @msg = nil
    return r
  end

  def messagesent
    @messagesent
  end

#  def lastmsg
#    @lastmsg
#  end
#
#  def lastmsg=(newlastmsg)
#    @lastmsg = newlastmsg
#  end
#  def msg=(newmsg)
#    @msg = newmsg
#  end
#  
#  def msg
#    @msg
#  end

  def xml4create
    raise ImsError, "xml4create must be overriden"
  end

  def xml4update
    raise ImsError, "xml4update must be overriden"
  end

  def xml4destroy
    raise ImsError, "xml4destroy must be overriden"
  end

  private

  def logger
    RAILS_DEFAULT_LOGGER
  end

end
