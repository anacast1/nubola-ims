class ParametersController < RootAdminController

  COLS = [ :app, :name, :input, :kind, :parameter_values, :default_value, :limited ]
  
  active_scaffold :parameter do |config|
    config.label='Paràmetros de aplicación disponibles'
    config.list.columns = COLS
    config.show.columns = COLS
    config.update.columns = COLS
    config.columns[:app].form_ui = :select
    config.list.sorting = { :app => :asc }
    config.columns["app"].clear_link
  end

end
