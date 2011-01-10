class AppsController < RootAdminRoleController

  LIST_COLS = [ :name, :unique_app_id, :host, :parameters ]
  CRE_COLS = [ :name, :unique_app_id, :logo_image, :host, :basesize, :ram, :cpu, :admin_user_available, :end_user_available, :short, :description, :url, :homepage_url, :fee, :instance_basename ]
  UPD_COLS = CRE_COLS
  COLS = ["dependencias"]

  active_scaffold :app do |config|
    config.list.columns = LIST_COLS
    config.update.columns = UPD_COLS
    config.columns[:dependencias].form_ui = :select
    config.create.multipart = true
    config.update.multipart = true
    config.label='Aplicaciones'

    config.create.columns = []
    config.create.columns.add_subgroup "Aplicacion" do |g|
      g.add CRE_COLS
    end
    config.create.columns.add_subgroup "Dependencias" do |g|
      g.add COLS
    end

    config.update.columns = []
    config.update.columns.add_subgroup "Aplicacion" do |g|
      g.add UPD_COLS
    end
    config.update.columns.add_subgroup "Dependencias" do |g|
      g.add COLS
    end

    config.columns["name"].label = "Nombre"
    config.columns["unique_app_id"].label = "Id. único"
    config.columns["logo_image"].label = "Logotipo"
    config.columns["basesize"].label = "Tamaño en vacío (MB)"
    config.columns["ram"].label = "Uso estimado de RAM (MB)"
    config.columns["cpu"].label = "Uso estimado de CPU (MHz)"
    config.columns["admin_user_available"].label = "Mostrar como instalable"
    config.columns["end_user_available"].label = "Mostrar como utilizable"
    config.columns["instance_basename"].label = "Parte común del nombre de cada instancia"
    config.columns["description"].label = "Descripción"
    config.columns["short"].label = "Descripción corta"
    config.columns["url"].label = "URL"
    config.columns["homepage_url"].label = "Web de la aplicación"
    config.columns["fee"].label = "Tarifa (€)"
    config.columns["host"].label = "Host compartido por defecto"
    config.columns[:host].form_ui = :select
  end

  protected

  def conditions_for_collection
    ['is_academy = 0']
  end

end
