class AcademiesController < RootAdminRoleController

  LIST_COLS = [ :name, :unique_app_id ]
  CRE_COLS  = [ :name, :unique_app_id, :logo_image, :admin_user_available, :end_user_available, :short, :description, :url, :homepage_url, :fee ]
  UPD_COLS  = CRE_COLS

  active_scaffold :apps

  active_scaffold :app do |config|
    config.list.label       = "Academias"
    config.list.columns     = LIST_COLS
    config.create.multipart = true
    config.create.columns   = CRE_COLS
    config.update.multipart = true
    config.update.columns   = UPD_COLS

    config.columns["name"].label                 = "Nombre"
    config.columns["unique_app_id"].label        = "Id. único"
    config.columns["logo_image"].label           = "Logotipo"
    config.columns["admin_user_available"].label = "Mostrar como instalable"
    config.columns["end_user_available"].label   = "Mostrar como utilizable"
    config.columns["description"].label          = "Descripción"
    config.columns["short"].label                = "Descripción corta"
    config.columns["url"].label                  = "URL"
    config.columns["homepage_url"].label         = "Web de la academia"
    config.columns["fee"].label                  = "Tarifa (€)"
  end

  protected

  def conditions_for_collection
    ['is_academy = 1']
  end

  def before_create_save(record)
    record.host       = Host.find_by_hostname(Setting.shared_host)
    record.basesize   = 0
    record.ram        = 0
    record.cpu        = 0
    record.is_academy = true
  end

  def after_create_save(record)
    parameter = Parameter.create!(:app_id => record.id, :name => "groupname", :input => "hidden", :kind => "user", :default_value => "User.groupname", :limited => 1)
    record.parameters << parameter

    parameter = Parameter.create!(:app_id => record.id, :name => "role", :input => "dropdown", :kind => "user", :default_value => "NoAdmin", :limited => 1)
    parameter_value = ParameterValue.create!(:parameter_id => parameter.id, :value => "NoAdmin")
    parameter.parameter_values << parameter_value
    parameter_value = ParameterValue.create!(:parameter_id => parameter.id, :value => "Admin")
    parameter.parameter_values << parameter_value

    record.parameters << parameter
    record.save!
  end
end

