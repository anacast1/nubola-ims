class UserSettingsController < RootAdminRoleController

  COLS = [ :parameter, :value ]
  
  active_scaffold :user_setting do |config|
    config.label='Preferéncias de usuario'
    config.list.columns = [:user] + COLS
    config.show.columns = [:user] + COLS
    config.update.columns = COLS
    config.columns[:parameter].form_ui = :select
  end

end
