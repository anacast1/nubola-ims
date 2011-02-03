# Envia missatges de backup per els grups clients,
# amb les aplicacions que tinguin instal.lades
# Execució:
#
#   script/runner BackupSender.send_backups()
#
class BackupSender
  def self.send_backups
    Contract.find_all_by_state(1).each do |c|
      unless c.group.installs.nil?
        c.group.installs.each do |i|
          message = c.group.backup_message([i.app], i.host.hostname)
          # TODO millorar això
          # els missatges de petició de backup es fan cada minut
          # per intentar espaiar els backups
          if system("#{Setting.oappublish} 'IMS' '#{message}'")
            logger.info("BackupSender. Publish <backup id='#{c.group.id}' host='#{i.host.hostname}'>") 
            sleep 120 unless Setting.standalone
          else
            logger.error("BackupSender. Can not publish <backup id='#{c.group.id}' host='#{i.host.hostname}'>")
          end
        end
      end
    end
  end

  private
  def self.logger
    RAILS_DEFAULT_LOGGER
  end
end
