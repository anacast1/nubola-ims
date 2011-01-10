class ConsumParamsController < AdminRoleController

  active_scaffold :consum_param do |config|
    config.label='Límites para las aplicaciones'
    config.columns = [ :code, :name, :app, :value ]
    config.columns["app"].form_ui = :select
    config.columns["app"].clear_link
    config.columns["code"].label = "Código"
    config.columns["name"].label = "Nombre"
    config.columns["app"].label = "Aplicación"
    config.columns["value"].label = "Valor por defecto"
  end

end
