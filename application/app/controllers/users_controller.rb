class UsersController < AdminRoleController

  COLS = [ :login, :password, :password_confirmation, :name, :surname, :telephone, :mobile, :email, :role, :group, :group_created_at, :apps, :confirmed, :user_settings, :status]

  active_scaffold :user do |config|
    config.label='users'
    config.columns = COLS
    config.list.columns = COLS - [ :password, :password_confirmation, :telephone, :mobile, :apps, :user_settings]
    config.show.columns = COLS
    config.create.columns = COLS - [:group_created_at]
    config.update.columns = COLS - [:group_created_at]
    config.columns[:apps].form_ui = :select
    config.columns[:group].form_ui = :select
    config.columns[:group_created_at].includes = [:group]
    config.columns[:group_created_at].sort_by :sql => "groups.created_at"
    config.list.sorting = { :group_created_at => :desc }
  end
  
end

