class HostsController < AdminRoleController

  COLS = [ :hostname, :status, :host_type, :groups ]

  active_scaffold :host do |config|
    config.create.multipart = true
    config.update.multipart = true
    config.label='Hosts Virtuales'
    config.columns["hostname"].label = "Hostname"
    config.columns["status"].label = "Estado"
    config.columns["host_type"].label = "Tipo de host"
    config.columns["groups"].label = "Grupo"
    config.list.columns = COLS
    config.list.sorting = { :hostname => :asc }
    config.create.columns = COLS
    config.update.columns = COLS
    config.columns[:host_type].form_ui = :select
    config.columns[:groups].form_ui = :select
    end

  # el host compartido no debe salir en el listado de hosts
  def conditions_for_collection
    ['hostname != ?', Setting.shared_host]
  end

end
