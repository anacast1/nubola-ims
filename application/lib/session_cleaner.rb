# Borra sessions expirades o sense usuari
# Execució:
#
#   script/runner SessionCleaner.clean()
#
# Se li pot passar com a paràmetre el timeout, si no l'intenta agafar del
# oap-sso (/etc/httpd/conf.d/mod_auth_sso.conf). Si no li passem i aquest fitxer
# no existeix utilitza 30 minuts de timeout per defecte.
class SessionCleaner

  def self.clean(timeout=nil)

     # buscar el timeout al fitxer .conf del modul mod_auth_sso si no l'hem especificat
     if timeout.nil?
       sso_file = "/usr/share/oaproject/mod_auth_sso/mod_auth_sso.conf"
       if File.exist?(sso_file)
         timeout  = IO.popen("egrep \"AuthSSO_Timeout \" #{sso_file} | awk '{print $2;}'").readlines.first.chop.to_i # massa complicat?
       else
         logger.info "SessionCleaner no troba fitxer: #{sso_file}, fa servir valor per defecte 30 per al timeout"
         timeout = 30
       end
     end

     # esborrem les sessions que han quedat sense usuari
     # (perque l'usuari no l'havia tancat i n'ha obert una altra)
     Session.destroy_all ["updated_at < ? AND (login = '' OR login is NULL)", Time.now - timeout.minutes]

     # per la resta, que tenen login, provoquem logout dels expirats
     Session.find(:all, :conditions => ["updated_at < ?", Time.now - timeout.minutes]).each do |s|

       user = User.find_by_login(s.login)

       # cas extrany en que haguem canviat el login d'un usuari a mà
       # i quedi una sessio penjada
       if user.nil?
         s.destroy
         next
       end
      
       # enviar missatge de logout
       message = user.send_logout_message(s.sessid)
       unless system("#{Setting.oappublish} 'SSO' '#{message}'")
         self.logger.error("Problem publishing logout message")
       end

       # actualitzar numlogins del grup
       group = Group.find_by_id(user.group_id)
       unless group.loginusers == 0
         numlogins = group.loginusers - 1
         group.update_attributes(:loginusers => numlogins)
       end
 
       # esborrem la session
       s.destroy

     end

  end

  private

  def self.logger
    RAILS_DEFAULT_LOGGER
  end

end
