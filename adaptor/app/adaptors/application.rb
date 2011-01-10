class ApplicationAdaptor < Adaptation::Adaptor
  
  def process message
    registra(message)
  end

  # Registra els missatges desconeguts (sense adaptador), perque
  # quan es rep un missatge sense adaptador es crida el process
  # del ApplicationAdaptor (la resta d'adaptadors hereden d'aquest).
  #
  # Si un adaptador implementa els seu propi mètode 'process', si vol
  # registrar el missatge haurà de cridar el mètode 'registra' des
  # del seu 'process', i si vol, implementar el seu propi metode 'registra'.
  def registra message

    # Si el missatge no està implementat Adaptation el passa de
    # moment com a String, perquè encara no sap convertir un missatge
    # qualsevol a un Adaptation::Message. Si està implementat el
    # passarà com a un objecte Adaptation::Message.
    if message.is_a?(String)
      action =  message[1..(message.index(/(>| )/) - 1)]
      user = User.find_by_login(extreu_atribut(message, "id"))
      group = Group.find_by_id(extreu_atribut(message, "gid"))
      Registre.create(:text => message, :action => action, :user => user, :group => group)
    elsif message.is_a?(Adaptation::Message) 
      user = User.find_by_login(message.id)
      group = Group.find_by_id(message.gid)
      Registre.create( :text => message.to_xml.to_s, :action => message.class.to_s.downcase, :user => user, :group => group )
    end

  end

  private

  def extreu_atribut(missatge, atribut)
    missatge.split(' ').reject{|x| x =~ /^[^#{atribut}]/}[0].gsub(/\/>|#{atribut}=|\"/, "") rescue nil
  end

end
