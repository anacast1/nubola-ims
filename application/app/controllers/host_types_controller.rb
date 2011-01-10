class HostTypesController < RootAdminRoleController

  UPD_COLS = [ :cpu, :disk, :ram, :price ]
  CRE_COLS = [ :name ] + UPD_COLS

  active_scaffold :host_type do |config|
    config.create.multipart = true
    config.update.multipart = true
    config.label='Tipos de host'
    config.columns["cpu"].label = "CPU (MHz)"
    config.columns["disk"].label = "Disco (MB)"
    config.columns["name"].label = "Nombre"
    config.columns["price"].label = "Precio (€)"
    config.columns["ram"].label = "RAM (MB)"
    config.list.columns = CRE_COLS
    config.list.sorting = { :disk => :asc }
    config.create.columns = CRE_COLS
    config.update.columns = UPD_COLS
  end

end
