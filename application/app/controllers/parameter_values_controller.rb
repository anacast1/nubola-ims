class ParameterValuesController < RootAdminController

  COLS = [ :parameter, :value ]
  
  active_scaffold :parameter_value do |config|
    config.label='Valores de un paràmetro de aplicación'
    config.list.columns = COLS
    config.show.columns = COLS
    config.update.columns = COLS
    config.columns[:parameter].form_ui = :select
  end

end
