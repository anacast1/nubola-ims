# Busca todos los grupos que tienen la demo caducada en mas de 30 dias.
# Envía mensajes de uninstall a todas sus aplicaciones.
# Borra todas las preferencias de usuario, de grupo y la relacion usuario->applicacion
# Busca sus posibles maquinas virtuales y las destruye.
# Busca sus imagenes guardadas en el IMS y las borra.
# Borra todos los cargos, registros, sesiones, ...
# Borra los usuarios del grupo y el grupo.
#
# Ejecucion:
#
#   script/runner DemoCleaner.clean_demos()

class DemoCleaner
  def self.clean_demos
    groups = Group.find(:all, :order => "created_at").reject{ |group| group.active? || (group.demo_ends + 30.days <=> Time.now) != -1 }
    groups.each do |group|
      users = group.users
      group.installs.each do |install|
        application = install.app
        application.parameters.each do |parameter|
          if (parameter.kind == "group" || parameter.kind == "global")
            gs = GroupSetting.find_by_group_id_and_parameter_id(group.id, parameter.id)
            if (gs)
              gs.destroy
            end
          end
          users.each do |user|
            if (parameter.kind == "user" || parameter.kind == "global")
              us = UserSetting.find_by_user_id_and_parameter_id(user.id, parameter.id)
              if (us)
                us.destroy
              end
            end
          end
        end
        users.each do |user|
          bind = user.binds.find_by_app_id(application.id)
          if (bind)
            bind.destroy
          end
        end
        install.update_attributes!(:status => "UNINSTALLING")
        message = group.uninstall_message([application], install.host.hostname)
        unless system("#{Setting.oappublish} 'IMS' '#{message}'")
          logger.error("Problem publishing uninstall message")
          return
        end
      end
      sleep(60)
      group.reload
      group.hosts.reject{ |host| host.compartido? }.each do |host|
        times = 0
        while (times < 30 && host.apps.size > 0)
          times = times + 1
          sleep(60)
          host.reload
        end
        if (host.apps.size > 0)
          logger.error("Problems uninstalling some application on host #{host.hostname}")
          return
        end
        host.update_attributes!(:status => "DELETING")
        host.send_xml_for_destroy
      end
      sleep(60)
      group.reload
      times = 0
      while (times < 30 && group.hosts.size > 1)
        times = times + 1
        sleep(60)
        group.reload
      end
      if (group.hosts.size > 1)
        logger.error("Problems deleting some host")
        return
      end
      group.update_attributes!(:hosts => [])
      users.each do |user|
        Session.destroy_all(["login = ?", user.login])
        user.destroy
      end
      if (group.contract)
        ConsumValue.destroy_all(["contract_id = ?", group.contract.id])
        group.contract.destroy
      end
      Uploadedimage.destroy_all(["group_id = ? ", group.id])
      Charge.destroy_all(["group_id = ? ", group.id])
      Registre.destroy_all(["group_id = ? ", group.id])
      group.destroy
    end
  end

  private
  def self.logger
    RAILS_DEFAULT_LOGGER
  end
end
